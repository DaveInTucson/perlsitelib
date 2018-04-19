################################################################################
# 2013-08-19
#
package WebLib::HTML::TableWriter2;

use strict;
use warnings;
use Carp;

use Object::Attributes qw/row_index/;

1;

#------------------------------------------------------------------------------
#
sub new
{
    my $caller = shift;
    my $class  = ref($caller) || $caller;

    my $self = bless {}, $class;

    $self->row_index(0);

    $self->_on_create(@_);

    return $self;
}

#------------------------------------------------------------------------------
# Called when object is created.  
#
sub _on_create
{
    my $self = shift;
    for (my $i = 0; $i < @_; $i++)
    {
	my ($attrib, $value) = ($_[$i], $_[$i+1]);
	if ($self->can($attrib))
	{ $self->$attrib($value) }
    }
}

#------------------------------------------------------------------------------
#
sub write_table
{
    my $self     = shift;
    my $fetchrow = shift;

    croak "You must provide a fetchrow callback function"
	unless defined $fetchrow && ref($fetchrow) eq 'CODE';

    $self->open_table;
    while (my $row = $fetchrow->())
    {
	$self->write_cells($self->get_cells($row));
	$self->row_index($self->row_index+1);
    }
    $self->close_table;
}


#------------------------------------------------------------------------------
#
sub get_table_attribs { () }

#------------------------------------------------------------------------------
#
sub open_table
{
    my $self = shift;

    my @attrs = $self->get_table_attribs;
    print "<table ", join(' ', @attrs), ">";
}

#------------------------------------------------------------------------------
#
sub close_table { print "</table>\n" }

# Override to provide attributes to all <tr> tags
sub get_tr_attribs { () }

# override to provide contents to display in row cells
sub get_cells { () }

#------------------------------------------------------------------------------
#
sub write_cells
{
    my $self = shift;
    print "<tr>";
    $self->write_row_with('td', @_);
    print "</tr>\n";
}

sub write_summary
{
    my $self = shift;
    print "<tbody>";
    print "<tr class='summary'>";
    $self->write_row_with('th', @_);
    print "</tr>\n";
}

sub write_row_with
{
    my $self   = shift;
    my $tag    = shift;
    my @values = @_;

    foreach my $value (@values)
    {
	my @attr = get_td_attribs($value);
	my $val  = get_td_text($value);
	print "<$tag ", join(' ', @attr), ">$val</td>";
    }
}

#------------------------------------------------------------------------------
#
sub get_td_attribs
{
    my $cell = shift;

    if (ref($cell) eq 'ARRAY')
    { return ("class=$cell->[1]") }

    if (ref($cell) eq 'HASH')
    {
	my @attribs;
	foreach my $key (keys %$cell)
	{
	    next if $key eq 'text';
	    push @attribs, "$key=" . attrib_quote($cell->{$key});
	}
	return @attribs;
    }

    return ()
}

#------------------------------------------------------------------------------
#
sub attrib_quote
{
    my $value = shift;
    $value =~ s/"/&quot;/g;
    return "\"$value\"";
}

#------------------------------------------------------------------------------
#
sub get_td_text
{
    my $cell = shift;

    my $value;
    if (ref($cell) eq 'ARRAY')
    { $value = $cell->[0] }
    elsif (ref($cell) eq 'HASH')
    { $value = $cell->{text} }
    else
    { $value = $cell }

    return defined $value ? $value : '';
}
