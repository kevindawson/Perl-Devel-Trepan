# -*- coding: utf-8 -*-
# Copyright (C) 2011 Rocky Bernstein <rocky@cpan.org>
use warnings; no warnings 'redefine';
use lib '../../../..';

package Devel::Trepan::CmdProcessor::Command::Display;
use English;

use if !defined @ISA, Devel::Trepan::DB::Display ;
use if !defined @ISA, Devel::Trepan::Condition ;
use if !defined @ISA, Devel::Trepan::CmdProcessor::Command ;

unless (defined @ISA) {
    eval "use constant ALIASES    => qw(disp);";
    eval "use constant CATEGORY   => 'data';";
    eval "use constant NEED_STACK => 0;";
    eval "use constant SHORT_HELP => 
         'Display expressions when entering debugger';"
}

use strict; use vars qw(@ISA); @ISA = @CMD_ISA;
use vars @CMD_VARS;  # Value inherited from parent
our $MIN_ARGS   = 1;      # Need at least this many
our $MAX_ARGS   = undef;  # Need at most this many - undef -> unlimited.

our $NAME = set_name();
our $HELP = <<"HELP";
${NAME} [format] EXP
 
Print value of expression EXP each time the program stops.  FMT may be
used before EXP and may be one of 'c' for char, 'x' for hex, 'o' for
octal, 'f' for float or 's' for string.

Examples:
   ${NAME} x > 10 

See also "undisplay", "enable", and "disable".
HELP

# This method runs the command
sub run($$) {
    my ($self, $args) = @_;
    my $proc = $self->{proc};
    my $display;
    my @args = @{$args};
    shift @args;

    $display = join(' ', @args);
    unless (is_valid_condition($display)) {
	$proc->errmsg("Invalid display: $display");
	return
    }
    my $disp = $proc->{displays}->add($display);
    if ($disp) {
	my $mess = sprintf("Display %d set", $disp->number);
	$proc->msg($mess);
    }
}

unless (caller) {
    require Devel::Trepan::CmdProcessor::Mock;
    my $proc = Devel::Trepan::CmdProcessor::Mock::setup();
    # my $cmd = __PACKAGE__->new($proc);
    # $cmd->run([$NAME]);
}

1;