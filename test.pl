#!/usr/local/bin/perl -w
use strict;
# use lib '../../';
use Math::BooleanEval;
use Test;


BEGIN { plan tests => 5 };


my ($bool);

$bool = Math::BooleanEval->new('(yes|no) & (yes ? 1 : 0)');

# evaluate each defined item in the expression to 1 or 0
foreach my $item (@{$bool->{'arr'}}){
	next unless defined $item;
	$item = ($item =~ m/^no|off|false|null$/i) ? 0 : 1;
}

# evaluate the expression
err_comp('basic evaluation', $bool->eval(), 1);

# reset and try again
$bool->reset;

# evaulate where true is false and false it true
foreach my $item (@{$bool->{'arr'}}){
	next unless defined $item;
	$item = ($item =~ m/^no|off|false|null$/i) ? 1 : 0;
}

# evaluate the expression again
err_comp('basic evaluation', $bool->eval(), 0);

# syntax checks
err_comp('basic evaluation', $bool->syntaxcheck, 1);
err_comp('basic evaluation', Math::BooleanEval::syntaxcheck($bool->{'expr'}), 1);
err_comp('basic evaluation', Math::BooleanEval::syntaxcheck('(yes|no) & (yes ? 1 | : 0)'), 0);





#------------------------------------------------------
# err_comp
#
sub err_comp {
	my ($testname, $is, $should) = @_;
	
	if($is ne $should) {
		print STDERR 
			"\n", $testname, "\n",
			"\tis:     $is\n",
			"\tshould: $should\n\n";	
		ok(0);
	}
	
	else
		{ok(1)}
}
#
# err_comp
#------------------------------------------------------

