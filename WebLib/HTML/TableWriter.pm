################################################################################
# 2013-08-19
#
package WebLib::HTML::TableWriter;

use strict;
use warnings;
use Carp;

use Object::Attributes qw/_row_count/;

our $name_prefix  = 'weblib';
our $table_class  = 'table-data';

my %type2class =
    (
     'text'    => 'l',
     'num'     => 'r',
     'caption' => 'c',
    );
1;

#------------------------------------------------------------------------------
#
sub new
{
    my $caller = shift;
    my $class  = ref($caller) || $caller;

    my $self = bless {}, $class;

    $self->_row_count(0);
    $self->_init(@_);

    return $self;
}

#------------------------------------------------------------------------------
#
sub _init {}

sub table_css_class { return "$name_prefix-$table_class" }

#------------------------------------------------------------------------------
#
sub write_table
{
    my $self = shift;

    my ($prefix, $separator, $suffix, $fetchrow);
    my ($sortable, $id);
    if (1 == @_ && ref($_[0]) eq 'CODE')
    { $fetchrow = shift }
    else
    {
	my %config = @_;
	$prefix    = $config{prefix};
	$separator = $config{separator};
	$suffix    = $config{suffix};
	$fetchrow  = $config{fetchrow};
	$id        = $config{id};
	$sortable  = $config{sortable};

    }

    croak "You must provide a fetchrow callback function"
	unless defined $fetchrow && ref($fetchrow) eq 'CODE';

    croak "You must provide an id on sortable tables"
	unless defined $id || !$sortable;

    $prefix    = '' unless defined $prefix;
    $separator = '' unless defined $separator;
    $suffix    = '' unless defined $suffix;

    my $in_table = 0;
    my $row_count = $self->_row_count(0);
    while (my $row = $fetchrow->())
    {
	if ($self->at_new_table($row))
	{
	    if ($in_table)
	    { print "</table>$separator" }
	    else
	    { print $prefix }

	    my @inner = ('table', "class='" . $self->table_css_class . "'");
	    push @inner, "id='$id'" if defined $id;

	    print "<", join(' ', @inner), ">\n";
	    $in_table = 1;
	}

	$self->write_headers($row);

	$self->_write_cells('td', $self->get_row($row));
	$self->_row_count(++$row_count);
    }

    if ($in_table)
    {
	$self->write_footer;
	print "</table>$suffix";
	if ($sortable)
	{
	    print "<script type='text/javascript'>";
	    print "${name_prefix}_make_table_sortable('$id')</script>\n"
	}
    }
}

#------------------------------------------------------------------------------
#
sub write_headers {}

#------------------------------------------------------------------------------
#
sub _write_cells
{
    my $self = shift;
    my $tag  = shift;

    my $row_class = '';
    if (ref($tag) eq 'ARRAY')
    {
	$row_class = $tag->[0];
	$tag       = $tag->[1];
    }

    print "<tr";
    print " class='$row_class'" if $row_class ne '';
    print ">";

    while (@_)
    {
	my $cell = shift;
	$cell = '' unless defined $cell;
	if (ref($cell)) # [$cell, $type]?
	{
	    unless (defined $cell->[1])
	    {
		$cell->[1] = 'num';
		$cell->[0] .= ' ???';
	    }
	    my $class = $type2class{$cell->[1]};
	    die "No class for type $cell->[1]" unless defined $class;
	    $cell = $cell->[0];
	    $cell = '' unless defined $cell;
	    print "<$tag class='$class'>$cell</$tag>";
	}
	else
	{ print "<$tag>$cell</$tag>" }
    }
    print "</tr>\n";
}

#------------------------------------------------------------------------------
# Child classes can override this method to produce multiple tables from the
# same dataset
#
sub at_new_table { return $_[0]->_row_count == 0 }

#------------------------------------------------------------------------------
#
sub get_row { () }

#------------------------------------------------------------------------------
#
sub write_footer {}
