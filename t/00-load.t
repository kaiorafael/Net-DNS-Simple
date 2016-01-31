#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Net::DNS::Simple' ) || print "Bail out!\n";
}

diag( "Testing Net::DNS::Simple $Net::DNS::Simple::VERSION, Perl $], $^X" );
