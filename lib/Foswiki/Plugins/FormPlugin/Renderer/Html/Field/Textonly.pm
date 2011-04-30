# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Textonly;

use strict;
use warnings;

use Foswiki::Plugins::FormPlugin::Constants;
use Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field ();
our @ISA = ('Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field');

=pod

=cut

sub _render {
    my ( $this, $renderingAttributes, $options ) = @_;

    my $name  = $renderingAttributes->{name};
    my $value = $renderingAttributes->{value};
    delete $renderingAttributes->{name};
    delete $renderingAttributes->{value};

    my $hiddenAttributes = {
        name  => $name,
        value => $value,
    };

    return CGI::span( $renderingAttributes, $value )
      . CGI::hidden($hiddenAttributes);
}

=pod

=cut

sub _optionAttributes {
    my ( $this, $options ) = @_;

    return undef if !$options;

    my $attributes = {
        name  => $options->{name},
        value => $options->{value}
    };
    $attributes->{id} = $options->{id} if defined $options->{id};

    return $attributes;
}

=pod

=cut

sub _extraAttributes {
    my ( $this, $options ) = @_;

    my @classes;

    push @classes, $Foswiki::Plugins::FormPlugin::Constants::TEXTONLY_CSS_CLASS;

    if ( $options->{class} ) {
        push @classes, $options->{class};
    }

    my $attributes = {
        class => join ' ',
        @classes
    };

    return $attributes;
}

1;

# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (c) 2007-2011 Arthur Clemens, Sven Dowideit, Eugen Mayer
# All Rights Reserved. Foswiki Contributors
# are listed in the AUTHORS file in the root of this distribution.
# NOTE: Please extend that file, not this notice.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version. For
# more details read LICENSE in the root of this distribution.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# For licensing info read LICENSE file in the installation root.
