package Math::BooleanEval;
use strict;

# version
use vars '$VERSION';
$VERSION = '1.00';


=head1 NAME

Math::BooleanEval - Boolean expression parser

=head1 SYNOPSIS

 use Math::BooleanEval;
 my $bool = Math::BooleanEval->new('yes|no');

 # evaluate each defined item in the expression to 1 or 0
 foreach my $item (@{$bool->{'arr'}}){
    next unless defined $item;
    $item = ($item =~ m/^no|off|false|null$/i) ? 0 : 1;
 }

 # evaluate the expression
 print $bool->eval();


=head1 DESCRIPTION

BooleanEval parses a boolean expression and creates an array of elements in 
the expression.  By setting each element to 1 or 0 you can evaluate the 
expression.  The expression is parsed on the standard boolean delimiters:

 & | () ! ? :

Using BooleanEval involves three steps: instantiate an object, loop 
through the elements of the expression setting each to 1 or 0, then 
call eval();

To create a new object, call new(), passing the expression as the 
single argument:

 $bool = BooleanEval->new('yes|no');

Generally the easiest way to set each element is to use a foreach loop:

 foreach my $item (@{$bool->{'arr'}}){
    next unless defined $item;
	$item = ($item =~ m/^no|off|false|null$/i) ? 1 : 0;
 }

Notice that the first thing to do at the top of the loop is to check if the 
item is defined.  If it is not defined leave it as it is.  Otherwise, use the 
item for whatever checks you like. In the example above we test if the item 
is one of the standard English words for false.  Set the item to 1 or 0, 
nothing else.

Finally, get the evaluation of the expression with the eval() method:

 print $bool->eval();

=head1 PUBLIC INTERFACE

=cut


#-------------------------------------------------------------------------
# new
# 

=head2 Math::BooleanEval->new(expression)

Instantiates a BooleanEval object.

=cut

sub new {
	my ($class, $expr)=@_;
	return undef unless (defined $expr);
	
	my $self = bless({}, $class);
	my ($fieldcount, @org);
	
	# create self
	$self->{'expr'}=$expr;
	$self->{'org'}=\@org;
	$self->{'blanks'} = {};
	$self->{'pos'} = 0;
	$self->{'auto_reset'} = 1;
	$fieldcount = 0;
	
	# parse
	while ($expr =~ m/([^\|\&\(\)\!\?\:]+)/go) {
		my $piece = $1;
		$piece =~ s|^\s+||gos;
		$piece =~ s|\s+$||gos;
		
		# if this is an empty space
		unless ($piece =~ m|\S|so) {
			undef $self->{'blanks'}->{$fieldcount};
			undef $piece;
		}
		
		push @org, $piece;
		$fieldcount++;
	}
	
	$self->reset;
	return $self;
}
# 
# new
#-------------------------------------------------------------------------


#-------------------------------------------------------------------------
# reset
# 

=head2 $bool->reset()

Resets the object for another round of setting and evaluating.  
The object automatically resets after C<eval()> unless you set
the C<auto_reset> property to false (by default it's true),
so it's not usually necessary to reset after calling C<eval>.

=cut

sub reset {
	my ($self) = @_;
	$self->{'arr'} = [@{$self->{'org'}}];
}
# 
# reset
#-------------------------------------------------------------------------


#------------------------------------------------------------------------------------------
# eval
# 

=head2 $bool->eval()

Evaluates the expression.  By the time you call this method you should have set 
all elements in the {'arr'} array to 1, 0, or left them undefined if that's how 
they were to begin with.  See examples above.

=cut

sub eval {
	my ($self, %opts)=@_;
	my ($i,$parms,$piece);
	$parms = $self->{'expr'};

	# change undefs to spaces or 0s
	$i=0;
	foreach $piece (@{$self->{'arr'}}) {
		if (defined $piece)
			{$piece = $piece ? 1 : 0}
		else {
			if (exists $self->{'blanks'}->{$i})
				{$piece = ''}
			else
				{$piece = '0'}
		}
		
		$i++;
	}
	
	$i = 0;
	$parms =~ s/[^\|\&\(\)\!\?\:]+/$self->{'arr'}[$i++]/go;

	# if just a string is requested
	if ($opts{'string'})
		{return $parms}

	# filter in just the safe characters
	if ($parms =~ m/^([0\s^\|\&\(\)\!\?\:1]+)$/o)
		{$parms = $1}
	else
		{die 'illegal syntax'}
	
	# auto reset if necessary
	$self->{'auto_reset'} and $self->reset;
	
	return eval($parms) ? 1 : 0 ;
}
# 
# eval
#------------------------------------------------------------------------------------------


#------------------------------------------------------------------------------------------
# syntaxcheck
# 

=head2 syntaxcheck()

Returns true if the expression is syntacally valid, false if not.  For 
example, "Me & You" would return true but "Me & | You" would return false.

C<syntaxcheck> can be called as either an object method:

  if ($bool->syntaxcheck)

or as a static sub:

  if (Math::BooleanEval::syntaxcheck($expr))

=cut

sub syntaxcheck {
	my ($self) = @_;
	my ($bool, $piece, $str);
	
	$bool = Math::BooleanEval->new(ref($self) ? $self->{'expr'} : $self);
	
	foreach $piece (@{$bool->{'arr'}}) {
		next unless defined $piece;
		$piece = 1;
	}
	
	$str = $bool->eval('string'=>1);
	
	if ($str =~ m/^([0\s^\|\&\(\)\!\?\:1]+)$/o)
		{$str = $1}
	else
		{return 0}
	
	return eval($str . ';1') ? 1 : 0;
}
# 
# syntaxcheck
#------------------------------------------------------------------------------------------


# return
1;

=head1 TERMS AND CONDITIONS

Copyright (c) 2000 by Miko O'Sullivan.  All rights reserved.  This program is 
free software; you can redistribute it and/or modify it under the same terms 
as Perl itself. This software comes with B<NO WARRANTY> of any kind.

=head1 AUTHOR

Miko O'Sullivan
F<miko@idocs.com>

Created: Sometime around the end of the twentieth century.  I'm kind of vague on the exact date.


=head1 VERSION

  Version 0.9    December 18, 2000
  Original release.
  
  Version 0.91   Oct 15, 2001
  Same as 0.9, but hopefully more properly packaged for CPAN.  We'll see.
  
  Version 1.00   July 11, 2002
  Added reset method.
  Cleaned up documentation.

=cut
