#!/usr/local/bin/perl -w
# 454_base36 - Convert numbers <==> 454 Base 36 encoded strings.
#
# Written by: James D. White, University of Oklahoma, Advanced Center
#   for Genome Technology
#
# 20090721 JDW - Add support for formats that include timestamps.
# 20081024 JDW - Add help via -h and via input.  Add support for X,Y
#		 coordinate pairs.  Add exit/quit command.
#
#Date Written: October 23, 2008

use strict;

our $Date_Last_Modified = "July 21, 2009";

our($my_name) = $0 =~ m"[\\/]?([^\\/]+)$";
$my_name ||= '454_base36.pl';

if (@ARGV && $ARGV[0] eq '-h')
  {
  help();
  exit;
  }

my @encode = ('A' .. 'Z', '0' .. '9');
my $encode = join('', @encode);
my $first_warn = 1;

while (<STDIN>)
  {
  chomp;
  s/^\s+//g;
  last if (m/^((q(uit)?)|(e(xit)?)|x)$/i);
  s/\s+//g;
  if (/^h(elp)?$/i)
    {
    help();
    next;
    }
  elsif ($_ eq '')
    {
    print qq(Type "quit" or "exit" to leave the program\n) .
          qq(Type "help" for more program information.\n)
      if ($first_warn);
    $first_warn = 0;
    next;
    }
  elsif (/^\d+$/)						# 1
    {
    my $num = $_;
    printf "%d = %s\n", $num, num_to_string($num);
    next;
    }
  elsif (/^(\d+),(\d+)$/)					# 2
    {
    my $input = $_;
    my $num = 4096 * $1 + $2;
    my $warn = '';
    $warn = ", X out of range" if $1 > 4095;
    $warn .= ", Y out of range" if $2 > 4095;
    my $string = num_to_string($num);
    $string = ('A' x (5 - length $string)) . $string;
    printf "X,Y = %s = %s%s\n", $input, $string, $warn;
    next;
    }
  elsif (/^XY=(\w*)$/i)						# 3
    {
    my $xy = $1;
    my $num = string_to_num($xy);
    my $x = $num >> 12;
    my $y = $num & 4095;
    my $warn = '';
    $warn = ", X out of range\n" if $x > 4095;
    printf "XY = %s, X = %d, Y = %d%s\n", $xy, $x, $y, $warn;
    next;
    }
  elsif (/^\w{6,14}$/i)					# 4, 5, 6, 7
    {
    my $string = $_;
    my $l = length($string);
    if (grep { $l == $_} (6, 7, 9, 14))
      {
      my $timestamp_num = string_to_num(substr($string, 0, 6));
      my $timestamp;
      my $warn = '';
      {
	use integer;
	my $q1 = $timestamp_num / 60;
	my $sec = $timestamp_num - 60 * $q1;
	my $q2 = $q1 / 60;
	my $min = $q1 - 60 * $q2;
	my $q3 = $q2 / 24;
	my $hr = $q2 - 24 * $q3;
	my $q4 = $q3 / 32;
	my $day = $q3 - 32 * $q4;
	my $q5 = $q4 / 13;
	my $mon = $q4 - 13 * $q5;
	my $year = 2000 + $q5;
	$timestamp = sprintf "%04d_%02d_%02d_%02d_%02d_%02d",
	  $year, $mon, $day, $hr, $min, $sec;
      }
      my $hash = ($l > 6) ? (", Hash = " . uc substr($string, 6, 1)) : '';
      my $region2 = ($l > 7) ? substr($string, 7, 2) : '';
      $warn .= ", Invalid Region value" if ($region2 ne '' &&
        ($region2 !~ /^\d{2}$/ || $region2 == 0 || $region2 > 16));
      my $region = ($region2 ne '') ? (",\n  Region = " . $region2) : '';
      my $xy = '';
      if ($l == 14)
        {
	my $num = string_to_num(substr($string, 9));
	my $x = $num >> 12;
	my $y = $num & 4095;
	$warn .= ", X out of range" if $x > 4095;
	$xy = sprintf ", X = %d, Y = %d", $x, $y;
	}
      print "Input=$string, Timestamp = $timestamp$hash$region$xy$warn\n";
      next;
      }
    }
  elsif (/^(\d{4})_(\d{2})_(\d{2})_(\d{2})_(\d{2})_(\d{2})$/)	# 8
    {
    my $input = $_;
    my($year, $mon, $day, $hr, $min, $sec) = ($1, $2, $3, $4, $5, $6);
    my $warn = '';
    $warn = "Year out of range\n" if ($year < 2000 || $year > 2059);
    $warn .= "Month out of range\n" if ($mon < 1 || $mon > 12);
    $warn .= "Day out of range\n" if ($day < 1 || $day > 31);
    $warn .= "Hour out of range\n" if ($hr > 23);
    $warn .= "Minute out of range\n" if ($min > 59);
    $warn .= "Second out of range\n" if ($mon > 59);
    if ($warn)
      {
      print $warn;
      next;
      }
    my $num = $sec + 60 * ($min + 60 * ($hr +
      24 * ($day + 32 * ($mon + 13 * ($year - 2000)))));
    my $string = num_to_string($num);
    $string = ('A' x (5 - length $string)) . $string;
    printf "Timestamp = %s = %s\n", $input, $string;
    next;
    }
  my $string = $_;						# 9
  $string =~ s/\s+//g;
  printf "%s = %d\n", $string, string_to_num($string);
  } # end while (<STDIN>)

exit;

sub num_to_string
  {
  my($num) = @_;
  my @string = ();
  while ($num > 0)
    {
    my $rem = $num % 36;
    $num = ($num - $rem) / 36;
    unshift @string, $rem;
    }
  my $string = '';
  $string .= $encode[$_] foreach @string;
  $string ||= 'A';
  return $string;
  } # end num_to_string

sub string_to_num
  {
  my($string) = @_;
  $string =~ tr/a-z/A-Z/;
  my $num = 0;
  while ($string ne '')
    {
    my $char = substr($string, 0, 1, '');
    my $digit = index($encode, $char);
    return -1 if ($digit == -1);
    $num = 36 * $num + $digit;
#print " num=$num, digit=$digit, string='$string'\n";
    }
  return $num;
  } # end string_to_num


######################################################################
# help() - Print information about this program
######################################################################

sub help
  {
  print STDOUT <<ENDHELP;

$my_name - Convert numbers to and from 454 Base 36 encoded
strings.


USAGE: $my_name [-h]


OPTIONS:

  -h  - Print the help you are reading.


Each 454 base 36 character is from the set [A-Z0-9] representing
values 0 - 35, respectively.

Input is via STDIN and is case independent. Output is via STDOUT.

You can leave the program by typing "exit" or "quit". You can get this
help inside the program by typing "help".

1) If a number is entered (e.g., 1053908), the number is printed
   along with the converted string. (e.g., "1053908 = AWVHI")

2) If the input is "number,number" (e.g., 375,3214), the input is
   assumed to be an X,Y coordinate pair and printed along with the
   converted string. (e.g., "X,Y = 375,3214 = A69X8")

3) If the input is "XY=string" (e.g., XY=A69X8), the string is assumed
   to be an X,Y coordinate string and printed along with the converted
   X and Y numeric values. (e.g., "XY = A69X8, X = 375, Y = 3214")

4) If the input is a six character alphanumeric string (e.g., FYJA19),
   the string is assumed to be a timestamp.  The timestamp will be
   printed.

5) If the input is a seven character alphanumeric string (e.g.,
   FYJA19Y), the string is assumed to be an SFF name without a region
   number.  The timestamp and hash will be printed.

6) If the input is a nine character alphanumeric string (e.g.,
   FYJA19Y04), the string is assumed to be an SFF including the region
   number.  The timestamp, hash, and region will be printed.

7) If the input is a fourteen character alphanumeric string (e.g.,
   FYJA19Y04J242H), the string is assumed to be a universal accession
   number.  The timestamp, hash, region, and X, Y coordinates will be
   printed.

8) If the input is an alphanumeric string of the form
   yyyy_mm_dd_hh_mm_ss (e.g., 2009_07_02_15_09_35), the string is
   assumed to be a timestamp, consisting of the four-digit year,
   followed by two-digit, month, day of month, hour, minute, and
   second.  The six-character timestamp will be printed.

9) If a string is entered which does not match the above (e.g., AWVHI),
   it is printed along with the converted decimal integer. (e.g.,
   "AWVHI = 1053908")


DATE LAST MODIFIED: $Date_Last_Modified

ENDHELP
  } # end help

