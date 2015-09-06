#!/usr/bin/perl
# vi: ft=perl

# FIXME: Add themes column?

use strict;
use warnings;
use Text::CSV;
use HTML::Parser ();
use Data::Dumper;
use HTML::TokeParser::Simple;

my $outfile = 'out.csv';
open(my $io, ">$outfile") or die "can't open $outfile: $!\n";
#my $io = *STDOUT;
my(@codes) = qw/WTD SPL CPL GAP RAT ROF RCL RTC WTDD RFW POC MOP RPP WIL/;
my @keep = ('Key','Publication Year','Author','Title');
my %keep = map { $_ => 1 } (@keep,'Notes');

my $csv = Text::CSV->new({binary => 1, eol => $/}) or die "Cannot use CSV: ".Text::CSV->error_diag ();
my $f   = "rcos.csv";
open my $rcos, "<:encoding(utf8)", $f or die "$f: $!";
my($colnames) = $csv->getline($rcos);
#FIXME: Seem to have to resave using LibreOffice Calc before columns can be read
! defined($colnames) && die("Resave using calc to fix headers? ",Dumper($colnames));
$csv->column_names($colnames);
$csv->print($io,[@keep,@codes]);

while (my $row = $csv->getline_hr($rcos) ) {
  map { delete($row->{$_}) } grep { not exists $keep{$_} } keys(%$row); # delete unwanted fields
  $csv->column_names(@keep,@codes);

  # get notes by code
  map { $row->{$_} = [] } @codes;
  my $p = HTML::TokeParser::Simple->new(string => $row->{Notes});
  while (my $token = $p->get_token) {
    # This prints all text in an HTML doc (i.e., it strips the HTML)
    next unless $token->is_text;
    my $note = $token->as_is;
    next if $note =~ /^;/;
    my($code,$text) = $note =~ /^(\w+):(.*$)/;
    push(@{$row->{$code}},$text);
  }
  delete($row->{Notes});
  for my $code (@codes) {
    my(@points) = @{$row->{$code}};
    if (@points) {
      $row->{$code} = '';
      for (my $i = 1; $i <= $#points + 1; $i++) {
	print("${i}. $points[$i-1]\n");
	$row->{$code} .= "${i}. $points[$i-1]\n";
      }
    } else {
      $row->{$code} = '';
    }
  }
  $csv->print_hr($io,$row);
  $csv->column_names($colnames);
}
close($outfile);
