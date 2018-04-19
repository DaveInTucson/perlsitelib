################################################################################
# 2013-08-19
#
package WebLib::Date;

use strict;
use warnings;
use Carp;

use Date::Day;

use Exporter;
our @ISA = qw/Exporter/;

our @EXPORT = qw/date_format/;

my %format_fn_table = (
    '%' => sub { '%' },
    'a' => \&_format_day3,
    'A' => \&_format_day,
    'm' => \&_format_month3,
    'M' => \&_format_month,
    'd' => sub { sprintf "%d", $_[3] },
    'Y' => sub { $_[1] }
    );

my %day3_to_day_full = (
    Sun => 'Sunday',
    Mon => 'Monday',
    Tue => 'Tuesday',
    Wed => 'Wednesday',
    Thu => 'Thursday',
    Fri => 'Friday',
    Sat => 'Saturday',
    
);
my @months = ('month zero',
	      'January',
	      'February',
	      'March',
	      'April',
	      'May',
	      'June',
	      'July',
	      'August',
	      'September',
	      'October',
	      'November',
	      'December');

my @months3 = ('month zero',
	       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
	       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec');

1;

sub date_format
{
    my $format = shift;
    my $date   = shift;

    my ($year, $month, $day) = parse_date($date);

    my @fdate;
    while ($format ne '')
    {
	if ($format =~ /^([^%]+)(.*)$/)
	{ push @fdate, $1; $format = $2; next }

	$format =~ /^%(-?\d*)(.)(.*)$/
	    || die "Expecting %. format: $format";

	my ($parm, $fc) = ($1, $2);
	$format = $3;

	my $format_fn = $format_fn_table{$fc};
	croak "Undefined format code '$fc'" unless defined $format_fn;
	push @fdate, $format_fn->($parm, $year, $month, $day);
    }

    return join('', @fdate);
}

sub parse_date
{
    my $date = shift;

    if ($date =~ /^(\d\d\d\d)-(\d\d)-(\d\d)$/)
    {
	my ($year, $month, $day) = ($1, $2, $3);
	croak "month out of range on $date"
	    unless 1 <= $month && $month <= 12;
	croak "day out of range on $date"
	    unless 1 <= $day && $day <= 31;

	return ($year, $month, $day);
    }

    croak "Don't know how to parse date $date";
}

sub _format_day3
{
    my ($format, $year, $month, $day) = @_;

    my $day_name = day($month, $day, $year);
    croak "$day_name: No day for month=$month, day=$day, year=$year"
	if $day_name eq 'ERR';

    return ucfirst(lc($day_name));
}

sub _format_day
{
    my ($format, $year, $month, $day) = @_;

    my $day3 = _format_day3($format, $year, $month, $day);
    return $day3_to_day_full{$day3} || 'ERR';
}


sub _format_month3
{
    my ($format, $year, $month, $day) = @_;

    croak "Month $month is out of range"
	unless 1 <= $month && $month <= 12;

    return $months3[$month];
}

sub _format_month
{
    my ($format, $year, $month, $day) = @_;

    croak "Month $month is out of range"
	unless 1 <= $month && $month <= 12;

    return $months[$month];
}
