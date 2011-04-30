# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Date;

use strict;
use warnings;

use Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field ();
our @ISA = ('Foswiki::Plugins::FormPlugin::Renderer::Html::Field::Field');

use Foswiki::Plugins::FormPlugin::Renderer::Html::FieldFactory;
use Foswiki::Plugins::FormPlugin::Util;
use Foswiki::Func;

=pod

=cut

sub _render {
    my ( $this, $renderingAttributes, $options ) = @_;

    my $dateOptions = $renderingAttributes;
    if ( !$options->{id} ) {
        $dateOptions =
          Foswiki::Plugins::FormPlugin::Util::mergeHashes( $options,
            { id => 'caldate' . ( int( rand(10000) ) + 1 ) } );
    }

    # generate text field
    my $textField =
      Foswiki::Plugins::FormPlugin::Renderer::Html::FieldFactory::getField(
        'text');
    my $text = $textField->render($dateOptions);

    my $dateField = $text;

    eval 'use Foswiki::Contrib::JSCalendarContrib';
    {
        if ($@) {
            my $mess = "WARNING: JSCalendar not installed: $@";
            print STDERR "$mess\n";
            Foswiki::Func::writeWarning($mess);
        }
        else {
            Foswiki::Contrib::JSCalendarContrib::addHEAD('foswiki');

            my $format =
                 $dateOptions->{dateFormat}
              || $Foswiki::cfg{JSCalendarContrib}{format}
              || "%e %B %Y";

            $dateField .= ' <span class="foswikiMakeVisible">';
            my $control = CGI::image_button(
                -class => 'editTableCalendarButton',
                -name  => 'calendar',
                -onclick =>
                  "return showCalendar('$dateOptions->{id}','$format')",
                -src => Foswiki::Func::getPubUrlPath() . '/'
                  . $Foswiki::cfg{SystemWebName}
                  . '/JSCalendarContrib/img.gif',
                -alt   => 'Calendar',
                -align => 'middle'
            );

            #fix generated html
            $control =~ s/MIDDLE/middle/go;
            $dateField .= $control;
            $dateField .= '</span>';
        }
    };
    return $dateField;
}

=pod

=cut

sub _renderDisabledAsHidden {
    my ( $this, $renderingAttributes ) = @_;

    return '';
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
