# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::Field::BaseMulti;

use strict;
use warnings;

use Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field ();
our @ISA = ('Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field');
use Foswiki::Plugins::FormPlugin::Util;
use Foswiki::Plugins::FormPlugin::Constants;

=pod

=cut

sub _optionAttributes {
    my ( $this, $options ) = @_;

    return undef if !$options;

    my %labels;
    @labels{ @{ $options->{optionList} } } = @{ $options->{labelList} }
      if $options->{labelList};

    my $attributes = {
        name    => $options->{name},
        values  => $options->{optionList},
        default => $options->{selectedOptionList},
        labels  => \%labels,
        size    => $options->{size}
    };
    $attributes->{id}       = $options->{id} if defined $options->{id};
    $attributes->{multiple} = 'true'         if $options->{hasMulti};
    $attributes->{tabindex} = $options->{tabindex}
      if defined $options->{tabindex};

    return $attributes;
}

=pod

Implemented by subclasses. 

=cut

sub _extraAttributes {
    my ( $this, $options ) = @_;

    return undef;
}

=pod

Adds hidden input field to pass disabled field data

=cut

sub _renderDisabledAsHidden {
    my ( $this, $renderingAttributes ) = @_;

    my $hiddenAttributes = {
        name  => $renderingAttributes->{name},
        value => join( ',', @{ $renderingAttributes->{selectedOptionList} } ),
    };
    return CGI::hidden($hiddenAttributes);
}

=pod

=cut

sub _fieldsetClass {
    my ( $this, $options ) = @_;

    my @classes;

    # group
    push @classes,
      $Foswiki::Plugins::FormPlugin::Constants::ELEMENT_GROUP_CSS_CLASS;

    if ( $options->{class} ) {
        push @classes, $options->{class};
    }

    # hint
    push @classes,
      $Foswiki::Plugins::FormPlugin::Constants::ELEMENT_GROUP_HINT_CSS_CLASS
      if $options->{hint};

    # mandatory
    push @classes, $Foswiki::Plugins::FormPlugin::Constants::MANDATORY_CSS_CLASS
      if $options->{mandatory};

    my $classList = $this->_cssClass( join ' ', @classes );
    return $classList;
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
