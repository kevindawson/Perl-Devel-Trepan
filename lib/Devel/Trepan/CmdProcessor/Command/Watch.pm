# -*- coding: utf-8 -*-
# Copyright (C) 2011-2012 Rocky Bernstein <rocky@cpan.org>
use warnings; no warnings 'redefine';
use rlib '../../../..';

package Devel::Trepan::CmdProcessor::Command::Watch;
use English qw( -no_match_vars );

use if !@ISA, Devel::Trepan::WatchMgr ;
use if !@ISA, Devel::Trepan::Condition ;
use if !@ISA, Devel::Trepan::CmdProcessor::Command ;

unless (@ISA) {
    eval <<'EOE';
#   eval "use constant ALIASES    => qw(w);";
use constant CATEGORY   => 'breakpoints';
use constant NEED_STACK => 0;
use constant SHORT_HELP => 
    'Set to enter debugger when a watched expression changes';
use constant MIN_ARGS   => 1;     # Need at least this many
use constant MAX_ARGS   => undef; # Need at most this many - undef -> unlimited.
EOE
}

use strict; use vars qw(@ISA); @ISA = @CMD_ISA;
use vars @CMD_VARS;  # Value inherited from parent

our $NAME = set_name();
our $HELP = <<'HELP';
=pod

watch I<Perl-expression>
 
Stop very time I<Perl-expression> changes from its prior value.

=head2 Examples:

 watch $a  # enter debugger when the value of $a changes
 watch scalar(@ARGV))  # enter debugger if size of @ARGV changes.

See also C<delete>, C<enable>, and C<disable> and C<info watch>.
=cut
HELP

# This method runs the command
sub run($$) {
    my ($self, $args) = @_;
    my $proc = $self->{proc};
    my $expr;
    my @args = @{$args};
    shift @args;

    $expr = join(' ', @args);
    unless (is_valid_condition($expr)) {
        $proc->errmsg("Invalid watch expression: $expr");
        return
    }
    my $wp = $proc->{dbgr}->{watch}->add($expr);
    if ($wp) {
        # FIXME: handle someday...
        # my $cmd_name = $args->[0];
        # my $opts->{return_type} = parse_eval_suffix($cmd_name);
        my $opts = {return_type => '$'}; 
        my $mess = sprintf("Watch expression %d: %s set", $wp->id, $expr);
        $proc->msg($mess);
        # FIXME: 4 below is a magic fixup constant.
        $proc->eval($expr, $opts, 4);
        $proc->{set_wp} = $wp;

        # Without setting $DB::trace = 1, it is possible
        # that a continue won't trigger calls to $DB::DB
        # and therefore we won't check watch expressions.
        $DB::trace = 1;
    }
}

unless (caller) {
    require Devel::Trepan::CmdProcessor::Mock;
    my $proc = Devel::Trepan::CmdProcessor::Mock::setup();
    # my $cmd = __PACKAGE__->new($proc);
    # $cmd->run([$NAME]);
}

1;
