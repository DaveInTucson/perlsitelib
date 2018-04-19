###############################################################################
# This package provides a simplified interface over the DBI database facility.
# If you only ever use a single database connection in your program, this
# makes database access much, much simpler.
#
# Note that this uses the Properties package.

package SimpleDB;

use strict;
use warnings;
use Carp;

use Properties;

use DBI;
use Exporter;

our @ISA = qw/Exporter/;

our @EXPORT = ('sdb_config',
	       'sdb_close',
	       'sdb_query',
	       'sdb_query_to_array',
	       'sdb_query_to_array_with_map',
	       'sdb_query_unique',
	       'sdb_execute',
	       );

my $g_dbh    = undef;
my $g_config = undef;

1;

#------------------------------------------------------------------------------
#
sub sdb_config
{
    my $config;
    if (1 == @_)
    {
	if (ref($_[0]) && $_[0]->isa('Properties'))
	{ $config = shift }
	elsif (-f $_[0])
	{
	    my $path = shift;
	    $config = new Properties($path) ||
		die "Cannot open $path: $!\n";
	}
	else { croak "don't know how to set config from $_[0]" }
    }
    elsif (@_ % 2 == 0)
    {
	$config = new Properties;
	while (@_)
	{
	    my $name = shift;
	    my $value = shift;
	    $config->set($name, $value);
	}
    }
    else
    {
	croak "Expecting Properties, path or list of name/value pairs";
    }

    $g_config = $config;
}

#------------------------------------------------------------------------------
#
sub sdb_open
{
    croak "No configuration specified" unless defined $g_config;

    my $source = $g_config->get('source');
    my $user   = $g_config->get('user');
    my $pass   = $g_config->get('pass');
    my $aflags = $g_config->get('attrib');

    croak "No source?" unless defined $source && $source ne '';

    my $attrib;
    $attrib = {map {$_=>1} split(',', $aflags) } if $aflags;
    $g_dbh = DBI->connect($source, $user, $pass, $attrib);
    die "Unable to connect to $source: $DBI::errstr\n"
	unless $g_dbh;
}

#------------------------------------------------------------------------------
#
sub sdb_close
{
    if ($g_dbh)
    {
	$g_dbh->disconnect;
	$g_dbh = undef;
    }
}

#-------------------------------------------------------------------------------
#
sub execute
{
    my $command = shift;
    my $args    = shift;

    my $sth = $g_dbh->prepare($command);
    eval {
	if ($args)
	{ $sth->execute(@$args) }
	else
	{ $sth->execute }
    };
    if ($@)
    {
	my $msg = $@;
	$msg =~ s|at [/a-zA-Z_]+\.pm.$||;
	croak "query failed: [$command]\n$msg";
    }

    return $sth;
}

#------------------------------------------------------------------------------
#
sub sdb_execute
{
    my $command = shift;
    my $args = shift;

    sdb_open unless defined $g_dbh;
    execute($command, $args);
}


#------------------------------------------------------------------------------
#
sub sdb_query
{
    my $query = shift;
    my $args = shift;

    sdb_open unless defined $g_dbh;
    my $sth = $g_dbh->prepare($query);
    eval {
	if ($args)
	{ $sth->execute(@$args) }
	else
	{ $sth->execute }
    };
    if ($@)
    {
	my $msg = $@;
	$msg =~ s|at [/a-zA-Z_]+\.pm.*$||;
	croak "query failed: [$query]\n$msg";
    }

    return sub { $sth->fetchrow_hashref };
}
    
#------------------------------------------------------------------------------
#
sub sdb_query_to_array
{
    my $cb = sdb_query(@_);
    my $array = [];
    while (my $row = $cb->())
    {
	push @$array, $row;
    }

    return $array;
}

#------------------------------------------------------------------------------
#
sub sdb_query_to_array_with_map
{
    my $map_fn = pop @_;
    croak "last argument must be a function"
        unless ref($map_fn) eq 'CODE';

    my $cb = sdb_query(@_);
    my $array = [];
    while (my $row = $cb->())
    {
        push @$array, $map_fn->($row);
    }

    return $array;
}

#------------------------------------------------------------------------------
#
sub sdb_query_unique
{
    my $results = sdb_query_to_array(@_);

    return undef         if 0 == @$results;
    return $results->[0] if 1 == @$results;
    croak "Query matched ", scalar @$results, " items: [$_[0]]"
}
