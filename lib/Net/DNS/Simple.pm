package Net::DNS::Simple;

use 5.006;
use strict;
use warnings;
use Net::DNS;

=head1 NAME

Net::DNS::Simple - The great new Net::DNS::Simple!

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

Quick summary of what the module does.

    use Net::DNS::Simple;

    my $foo = Net::DNS::Simple->new(<domain>, <qtype>);
    $foo->print_domain();
    ...

=cut

=head1 Methods

=head2 new

Initiate Net::DNS::Simple class object and defines the DNS protocol fields
header, answer, namser auth, and additional section.

    my $foo = Net::DNS::Simple->new("yahoo.com", "MX");

Internally, it uses Net::DNS::Resolver->send


    my %config = (
        nameservers => ['8.8.8.8', '8.8.4.4'],
        recurse => 0,
        debug => 0
     );

     my $res = Net::DNS::Simple->new("kaiux.com", "A", %config);

=cut

sub new {
	my $class  = shift; #class name
	my $domain = shift; #domain name constructor
	my $qtype  = shift; #query type given on constructor
	my $resolver = {@_}; #hash NameServer options
	
	my $self = bless {
		_domain_name => $domain,
		_qtype       => $qtype,

		#resolver opts
		_resolver =>  $resolver,

		#header
		_id      => undef, #query id
		_qrcode  => undef, #query or response
		_opcode  => undef, #Kind of Query RFC6895
		_rcode   => undef, #return code
		_qdcount => undef, #query count
		_ancount => undef, #answer count
		_nscount => undef, #authoritative count
		_arcount => undef, #additional count

		#answer IP
		_answer_ip => [],

		#authoritative ip
		_nsauth_ip => [],

		#additional section ip
		_arsect_ip => []

	}, $class;

	# send query
	$self->query();

	return $self;
}

=head2 print_domain()

Provides a very basic output similiar to Dig.

=cut

sub print_domain {
	my $self = shift;

	print ";; HEADER SECTION:", "\n";
	print "Domain: ", $self->{_domain_name}, "\n";
	print "ID: ", $self->{_id}, "\n";
	print "QR: ", $self->{_qrcode}, "\n";
	print "OPcode: ", $self->{_opcode}, "\n";
	print "Rcode: ", $self->{_rcode}, "\n";

	print "\n";
	print ";; ANSWER SECTION:", "\n";
	foreach my $entry ( @{$self->{_answer_ip}} ) {
		print $entry , "\n";
	}

	print "\n";
	print ";; AUTHORITY SECTION:", "\n";
	foreach my $entry ( @{$self->{_nsauth_ip}} ) {
		print $entry , "\n";
	}

	print "\n";
	print ";; ADDITIONAL SECTION:", "\n";
	foreach my $entry ( @{$self->{_arsect_ip}} ) {
		print $entry , "\n";
	}

}

# Setup DNS header
sub set_dns_header {
	my ($self, $handler) = @_;

	## setting DNS HEADER
	$self->{_id}      = $handler->id;
	$self->{_qrcode}  = $handler->qr;
	$self->{_opcode}  = $handler->opcode;
	$self->{_rcode}   = $handler->rcode;
	$self->{_qdcount} = $handler->qdcount;
	$self->{_ancount} = $handler->ancount;
	$self->{_nscount} = $handler->nscount;
	$self->{_arcount} = $handler->arcount;
}

# populate DNS
# answer section
sub add_answer_rr {
	my ($self, $rr_entry) = @_;

	my $array_ref = $self->{_answer_ip};
	push @$array_ref, $rr_entry;
	#push @{ $self->{_class_array} }, $new_element;
}

# populate DNS
# authority section
sub add_auth_rr {
	my ($self, $rr_entry) = @_;

	my $array_ref = $self->{_nsauth_ip};
	push @$array_ref, $rr_entry;
}

# populate DNS
# additional section
sub add_additional_rr {
	my ($self, $rr_entry) = @_;

	my $array_ref = $self->{_arsect_ip};
	push @$array_ref, $rr_entry;
}

# Query DNS
sub query {
	my $self = shift;

	my $d_resolver;
	my %config = %{$self->{_resolver}}; #hash reference

	#testing config
	if ( keys %config ) {
		$d_resolver = Net::DNS::Resolver->new(%config);
	} else {
		$d_resolver = Net::DNS::Resolver->new();
	}

	#Send the DNS Request
	my $d_handler = $d_resolver->send($self->{_domain_name}, $self->{_qtype});

	#check if we have some answer
	if ($d_handler) {
		#$d_handler->header->print;
		$self->set_dns_header($d_handler->header);
	}

	#get answer section
	if ($self->{_ancount} >= 1) {
		my @answer = $d_handler->answer;
		#print Dumper @answer;
		 foreach my $rr_info (@answer) {
			 $self->add_answer_rr($rr_info->string);
		 }
	}

	#get authority
	if ($self->{_nscount} >= 1) {
		my @authority = $d_handler->authority;
		foreach my $rr_info (@authority) {
			$self->add_auth_rr($rr_info->string);
		}
	}

	#get additional
	if ($self->{_arcount} >= 1) {
		my @additional = $d_handler->additional;
		foreach my $rr_info (@additional) {
			$self->add_additional_rr ($rr_info->string);
		}
	}

}

################
### Header data
################

=head2 get_qid()

Return Query ID used on this query.

=cut
#return QID
sub get_qid { my ($self) = @_; return $self->{_id}; }

=head2 get_opcode()

Return OpCode that specifies kind of query in this message.

=cut
#return opcode
sub get_opcode { my ($self) = @_; return $self->{_opcode}; }


=head2 get_rcode()

Return Responde Code (rcode).

=cut
#return rcode
sub get_rcode { my ($self) = @_; return $self->{_rcode}; }

=head2 get_qdcount()

Return integer specifying the number of entries in the question section.
=cut
#return query count
sub get_qdcount { my ($self) = @_; return $self->{_qdcount}; }

=head2 get_qdcount()

Return integer specifying the number of entries in the answer section.
=cut
#return answer count
sub get_ancount { my ($self) = @_; return $self->{_ancount}; }

=head2 get_nscount()

Return integer specifying the number of name server
resource records in the authority records section.
=cut
#return authorative count
sub get_nscount { my ($self) = @_; return $self->{_nscount}; }

=head2 get_arcount()

Return integer specifying the number of 
resource records in the additional records section.
=cut
#return additional count
sub get_arcount { my ($self) = @_; return $self->{_arcount}; }

################
### Answer data
################

=head2 get_answer_section()

Return a list of data (domain, ttl, IP) found on answer section.
=cut
#return answer section
sub get_answer_section { my ($self) = @_; return @{$self->{_answer_ip}}; }

=head2 get_authorative_section()

Return a list of data (domain, ttl, IP) found on authorative section.
=cut
#return authorative section
sub get_authorative_section { my ($self) = @_; return @{$self->{_nsauth_ip}}; }

=head2 get_additional_section()

Return a list of data (domain, ttl, IP) found on additional section.
=cut
#return additional section
sub get_additional_section { my ($self) = @_; return @{$self->{_arsect_ip}}; }

=head1 AUTHOR

Kaio Rafael (kaiux), C<< <perl at kaiux.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-dns-simple at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-DNS-Simple>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::DNS::Simple


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-DNS-Simple>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-DNS-Simple>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-DNS-Simple>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-DNS-Simple/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Kaio Rafael (kaiux).

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.


=cut

1; # End of Net::DNS::Simple
