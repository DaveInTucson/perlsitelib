################################################################################
# This is a (relatively) simple package to inject attribute accessor functions
# into the using package. It's assumed that the package is hash-based.
#
package Object::Attributes;

use strict;
use warnings;
use warnings::register;
use Carp;

my %is_keyword = map {$_ => 1} qw/BEGIN INIT CHECK END DESTROY AUTOLOAD/;

my %is_forced_into_main = map {$_ => 1}
    qw/STDIN STDOUT STDERR ARGV ARGVOUT ENV INC SIG/;

my %error_message =
    (
     invalid  => 'is not a valid identifier',
     reserved => 'begins with \'__\'',
     keyword  => 'is a Perl keyword',
     forced_into_main => 'is forced into main::',
    );


#------------------------------------------------------------------------------
#
sub import
{
    shift; # first arg is 'Object::Attributes'; don't care

    my $object_package = caller;

    foreach my $attribute_name (@_)
    {
	_declare_accessors($object_package, $attribute_name);
    }
}

#------------------------------------------------------------------------------
#
sub _declare_accessors
{
    my ($object_package, $attribute_name) = @_;

    my $modifier = '';
    if ($attribute_name =~ /^(.+)\+(.+)$/)
    {
	($attribute_name, $modifier) = ($1, $2);
    }

    _validate_accessor_name($attribute_name);

    my $method_name = $object_package . '::' . $attribute_name;
    my $attribute_key = "OA $method_name";

    my $method_body  = sub
    {
	my $self = shift;
	if (@_)
	{
	    my $value = $self->{$attribute_key} = $_[0];
	    return $value;
	}
	return $self->{$attribute_key};
    };

    if ($modifier eq 'onset')
    {
	my $onset_name  = "onset_$attribute_name";
	$method_body  = sub
	{
	    my $self = shift;
	    if (@_)
	    {
		my $value = $self->{$attribute_key} = $_[0];
		$self->$onset_name($value) if $self->can($onset_name);
		return $value;
	    }
	    return $self->{$attribute_key};
	};
    }

    no strict 'refs';
    *{$method_name} = $method_body;
}

#------------------------------------------------------------------------------
#
sub _validate_accessor_name
{
    my $name = shift;

    croak _make_error_message('invalid', $name)
	unless $name =~ /^[a-z_][a-z0-9_]*$/i;

    croak _make_error_message('reserved', $name)
	if $name =~ /^__/;

    if (warnings::enabled())
    {
	carp _make_error_message('keyword', $name)
	    if $is_keyword{$name};

	carp _make_error_message('forced_into_main', $name)
	    if $is_forced_into_main{$name};
    }
}

#------------------------------------------------------------------------------
#
sub _make_error_message
{
    my ($error_key, $name) = @_;

    return "Object::Attributes: '$name' $error_message{$error_key}";
}
