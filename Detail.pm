package WWW::GLS::Detail;
use strict;
#use warnings;
use Exporter;
our @ISA = qw/Exporter/;
our @EXPORT = qw/glscheck/;
our $VERSION = '0.2';
use LWP::Simple;

sub glscheck {
	my $paketnummer = shift;
	my $language = shift || 'de';

	my @newdata;
	my $data = get("http://www.gls-group.eu/276-I-PORTAL-WEB/content/GLS/DE03/".uc($language)."/5004.htm?txtRefNo=$paketnummer&txtAction=71000");
	$data =~ s/[\n\r]//g;

	my($detail) = ($data =~ /<table class="resultlist">(.*?)<\/table>/);
	while($detail =~ /<tr class="details">(.*?)<\/tr>/ig){
		my $detailone = $1;

		my($datum,$ort,$event,$daten) = ($detailone =~ /<td>\s*([^<]*)\s*<\/td>\s*<td>\s*([^<]*)\s*<\/td>\s*<td>\s*([^<]*)\s*<\/td>\s*<td>\s*([^<]*)\s*<\/td>/);
		$datum =~ s/\s\s*/ /g;
		$ort =~ s/\s\s*/ /g;
		$event =~ s/\s\s*/ /g;
		$daten =~ s/\s\s*/ /g;
		my %details;
		$details{'datum'} = $datum;
		$details{'ort'} = $ort;
		$details{'daten'} = $daten;
		$details{'event'} = $event;
		push(@newdata,\%details)
	}
	my($signatur) = ($data =~ /<td class="title">\s*(?:Signatur|Signature):\s*<\/td>\s*<td class="value">\s*([^<]*)\s*<\/td>/i);
	my($fromdate) = ($data =~ /<td class="title">\s*(?:Abhol-Datum|Pick-Up Date):\s*<\/td>\s*<td class="value">\s*([^<]*)\s*<\/td>/i);
	my($todate) = ($data =~ /<td class="title">\s*(?:Zustell-Datum|Delivery Date):\s*<\/td>\s*<td class="value">\s*([^<]*)\s*<\/td>/i);
	my($paketnumber) = ($data =~ /<td class="title">\s*(?:Paketnummer|Parcel Number):\s*<\/td>\s*<td class="value">\s*([^<]*)\s*<\/td>/i);
	my($referenznummer) = ($data =~ /<td class="title">\s*(?:Kundeneigene Referenznummer|Customer's own reference number):\s*<\/td>\s*<td class="value">\s*([^<]*)\s*<\/td>/i);
	my($gewicht) = ($data =~ /<td class="title">\s*(?:Gewicht|Weight):\s*<\/td>\s*<td class="value">\s*([^<]*)\s*<\/td>/i);
	my($produkt) = ($data =~ /<td class="title">\s*(?:Produkt|Product):\s*<\/td>\s*<td class="value">\s*([^<]*)\s*<\/td>/i);

	return(\@newdata,({
		'shipnumber' => $paketnumber,
		'signature' => $signatur,
		'pickupdate' => $fromdate,
		'deliverydate' => $todate,
		'reference' => $referenznummer,
		'weight' => $gewicht,
		'product' => $produkt
		})
	);
}


=pod

=head1 NAME

WWW::GLS::Detail - Perl module for the GLS online tracking service with details.

=head1 SYNOPSIS

	use WWW::GLS::Detail;
	my($newdata,$other) = glscheck('paketnumber','de');#de or en for text in german or english

	foreach my $key (keys %$other){# shipnumber, signature, pickupdate, deliverydate, reference, weight, product
		print $key . ": " . ${$other}{$key} . "\n";
	}
	print "\nDetails:\n";

	foreach my $key (@{$newdata}){
		#foreach my $key2 (keys %{$key}){#datum, event, ort, daten
		#	print ${$key}{$key2};
		#	print "\t";
		#}

		print ${$key}{datum};
		print "\t";
		print ${$key}{event};
		print "\t";
		print ${$key}{ort};
		print "\t";
		print ${$key}{daten};
		print "\n";
	}

=head1 DESCRIPTION

WWW::GLS::Detail - Perl module for the GLS online tracking service with details.

=head1 AUTHOR

    -

=head1 COPYRIGHT

	This program is free software; you can redistribute
	it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO



=cut
