#!/usr/bin/perl
# vi: ft=perl

# FIXME: Add themes column?

use strict;
use warnings;
use Text::CSV;
use HTML::Parser ();
use Data::Dumper;
use HTML::TokeParser::Simple;

my $outfile = 'rcos.csv';
open(my $io, ">$outfile") or die "can't open $outfile: $!\n";
#my $io = *STDOUT;
my(@codes) = qw{ROF SPL CPL GAP POC RPP POC/RPP RAT WTD RCL RTC WTDD RFW MOP WIL};
my @keep = ('Key','Publication Year','Author','Title');
my %keep = map { $_ => 1 } (@keep,'Notes');

my $csv = Text::CSV->new({binary => 1, eol => $/}) or die "Cannot use CSV: ".Text::CSV->error_diag ();
my $f   = "out.csv";
open my $in, "<:encoding(utf8)", $f or die "$f: $!";
my($colnames) = $csv->getline($in);
#FIXME: Seem to have to resave using LibreOffice Calc before columns can be read
! defined($colnames) && die("Resave using calc to fix headers? ",Dumper($colnames));
$csv->column_names($colnames);
$csv->print($io,[@keep,@codes]);

while (my $row = $csv->getline_hr($in) ) {
  map { delete($row->{$_}) } grep { not exists $keep{$_} } keys(%$row); # delete unwanted fields
  $csv->column_names(@keep,@codes);

  # get notes by code
  # FIXME: handle non-coded notes
  map { $row->{$_} = [] } @codes;
  my $p = HTML::TokeParser::Simple->new(string => $row->{Notes});
  while (my $token = $p->get_token) {
    # FIXME: notes get wrapped in <p>, so we want everything inside *except* the HTML tags
    # A quick hack to avoid HTML issues is to select the note text, switch to
    # HTML view and paste it in, which removes lots of <font> tags etc. (or
    # paste into HTML view initially)
    # 
    # This prints all text in an HTML doc (i.e., it strips the HTML)
    # ... but it truncates notes at the first embedded HTML tag e.g. <p>this is <em>italic</em></ap
    # gives "this is"
    next unless $token->is_text;
    my $note = $token->as_is;
    next if $note =~ /^;/;
    my($code,$text) = $note =~ m&^(\w{3}.?\w?\w?\w?):(.*$)&;
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
