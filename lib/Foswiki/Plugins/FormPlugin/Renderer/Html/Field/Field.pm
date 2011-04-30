# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field;

use strict;
use warnings;

use List::MoreUtils qw(uniq);
use Foswiki::Plugins::FormPlugin::Util;

=pod

=cut

sub new {
    my $class = shift;

    my $this = bless( {}, $class );
    return $this;
}

=pod

=cut

sub render {
    my ( $this, $options ) = @_;

    my $renderingAttributes = $this->_renderingAttributes($options);
    my $rendered = $this->_render( $renderingAttributes, $options );

    $rendered .= $this->_renderDisabledAsHidden($options)
      if $options->{disabled};

    return $rendered;
}

=pod

=cut

sub _render {
    my ( $this, $renderingAttributes, $options ) = @_;

    # implemented in subclasses
    return '';
}

=pod

Adds hidden input field to pass disabled field data

=cut

sub _renderDisabledAsHidden {
    my ( $this, $renderingAttributes ) = @_;

    my $hiddenAttributes = {
        name  => $renderingAttributes->{name},
        value => $renderingAttributes->{value}
    };
    return CGI::hidden($hiddenAttributes);
}

=pod

=cut

sub _renderingAttributes {
    my ( $this, $options ) = @_;

    return undef if !$options;

    my $attributes      = $this->_optionAttributes($options);
    my $extraAttributes = $this->_extraAttributes($options);
    my $renderingAttributes =
      Foswiki::Plugins::FormPlugin::Util::mergeHashes( $attributes,
        $extraAttributes );

    return $renderingAttributes;
}

=pod

=cut

sub _optionAttributes {
    my ( $this, $options ) = @_;

    return undef;
}

=pod

=cut

sub _extraAttributes {
    my ( $this, $options ) = @_;

    return undef;
}

=pod

=cut

sub _cssClass {
    my ( $this, $classString ) = @_;

    $classString ||= '';

    my @unique = uniq( split( ' ', $classString ) );
    return join( ' ', @unique );
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
