# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rockyb@rubyforge.net>
use strict; use warnings; no warnings 'redefine';
use English;
use lib '../..';
use Devel::Trepan::DB::Breakpoint;
package Devel::Trepan::BrkptMgr;

sub new($) 
{
    my $class = shift;
    my $self = {};
    bless $self, $class;
    $self->clear();
    $self;
}

sub clear($) 
{
    my $self = shift;
    $self->{list} = [];
    $self->{next_id} = 1;
}    

sub inspect($) 
{
    my $self = shift;
    my $str = '';
    for my $brkpt (@{$self->{list}}) {
	next unless defined $brkpt;
	$str .= $brkpt->inspect . "\n";
    }
    $str;
}    

# Remove all breakpoints that we have recorded
sub DESTROY() {
    my $self = shift;
    # for my $bp (@{$self->{list}}) {
    #     $bp->delete;
    # }
    $self->{clear};
}

sub delete($$)
{
    my ($self, $index) = @_;
    my @list = @$self->{list};
    my $bp = $list[$index];
    if (defined ($bp)) {
        $self->delete_by_brkpt($bp);
        return $bp;
    } else {
        return undef;
    }
}

sub delete_by_brkpt($$)
{
    my ($self, $delete_bp) = @_;
    for my $candidate (@{$self->{list}}) {
	next unless defined $candidate;
	if ($candidate eq $delete_bp) {
	    $candidate = undef;
	    # $delete_bp->remove();
	    return $delete_bp;
	}
    }
    return undef;
}

sub add($$)
{
    my ($self, $brkpt) = @_;
    push @{$self->{list}}, $brkpt;
    return $brkpt;
}

sub compact($)
{
    my $self = shift;
    my @new_list = ();
    for my $brkpt (@{$self->{list}}) {
	next unless defined $brkpt;
	push @new_list, $brkpt;
    }
    $self->{list} = \@new_list;
    return $self->{list};
}

sub is_empty($)
{
    my $self = shift;
    $self->compact();
    return scalar(0 == @{$self->{list}});
}

sub max($)
{
    my $self = shift;
    my $max = 0;
    for my $brkpt (@{$self->{list}}) {
	$max = $brkpt->num if $brkpt->num > $max;
    }
    return $max;
}

sub size($)
{
    my $self = shift;
    $self->compact();
    return scalar @{$self->{list}};
}

sub reset($)
{
    my $self = shift;
    # for my $bp (@$self->{list}) {
    # 	$bp->remove();
    # }
    $self->{list} = [];
}


unless (caller) {

    sub bp_status($$)
    { 
	my ($brkpts, $i) = @_;
	printf "list size: %s\n", $brkpts->size();
	printf "max: %d\n", $brkpts->max() // -1;
	print $brkpts->inspect();
	print "--- ${i} ---\n";
    }

my $brkpts = Devel::Trepan::BrkptMgr->new;
bp_status($brkpts, 0);
my $brkpt1 = DBBreak->new(
    type=>'brkpt', condition=>'1', num=>1, hits => 0, enbled => 1,
    negate => 0
    );

$brkpts->add($brkpt1);
bp_status($brkpts, 1);

my $brkpt2 = DBBreak->new(
    type=>'brkpt', condition=>'x>5', num=>2, hits => 0, enbled => 0,
    negate => 0
    );
$brkpts->add($brkpt2);
bp_status($brkpts, 2);

$brkpts->delete_by_brkpt($brkpt1);
bp_status($brkpts, 3);

my $brkpt3 = DBBreak->new(
    type=>'brkpt', condition=>'y eq x', num=>3, hits => 0, enbled => 1,
    negate => 1
    );
$brkpts->add($brkpt3);
bp_status($brkpts, 4);



  # p brkpts.delete(2)
  # p brkpts[2]
  # bp_status(brkpts, 3)

  # # Two of the same breakpoints but delete 1 and see that the
  # # other still stays
  # offset = frame.pc_offset
  # b2 = Trepan::Breakpoint.new(iseq, offset)
  # brkpts << b2
  # bp_status(brkpts, 4)
  # b3 = Trepan::Breakpoint.new(iseq, offset)
  # brkpts << b3
  # bp_status(brkpts, 5)
  # brkpts.delete_by_brkpt(b2)
  # bp_status(brkpts, 6)
  # brkpts.delete_by_brkpt(b3)
  # bp_status(brkpts, 7)
}

1;
