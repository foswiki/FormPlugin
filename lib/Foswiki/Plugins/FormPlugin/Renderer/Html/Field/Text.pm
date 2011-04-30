# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Text;

use strict;
use warnings;

use Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field ();
our @ISA = ('Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field');
use Foswiki::Plugins::FormPlugin::Util;

=pod

=cut

sub _render {
    my ( $this, $renderingAttributes, $options ) = @_;

    return CGI::textfield($renderingAttributes);
}

=pod

=cut

sub _optionAttributes {
    my ( $this, $options ) = @_;

    return undef if !$options;

    my $attributes = {
        name      => $options->{name},
        value     => $options->{value},
        size      => $options->{size},
        maxlength => $options->{maxlength}
    };
    $attributes->{id} = $options->{id} if defined $options->{id};
    $attributes->{tabindex} = $options->{tabindex}
      if defined $options->{tabindex};

    return $attributes;
}

=pod

=cut

sub _extraAttributes {
    my ( $this, $options ) = @_;

    my $attributes = {};

    $attributes->{class} ||= '';
    $attributes->{class} = "foswikiInputField";
    $attributes->{class} .= " $options->{class}" if $options->{class};
    $attributes->{class} .= ' foswikiInputFieldDisabled'
      if $options->{disabled};
    $attributes->{class} .= ' foswikiInputFieldReadOnly'
      if $options->{readonly};
    $attributes->{class} = $this->_cssClass( $attributes->{class} );
    Foswiki::Plugins::FormPlugin::Util::removeRedundantSpaces(
        $attributes->{class} );

    $attributes->{-disabled} = 'disabled' if $options->{disabled};
    $attributes->{-readonly} = 'readonly' if $options->{readonly};
    $attributes->{-placeholder} = $options->{placeholder}
      if $options->{placeholder};

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
