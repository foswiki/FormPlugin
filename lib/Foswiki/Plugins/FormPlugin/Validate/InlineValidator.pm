# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Validate::InlineValidator;

use strict;
use warnings;

use Foswiki::Func;
use Foswiki::Plugins::FormPlugin::Constants;

=pod

generateHeadText( \%validationRules, $formName ) -> ( $headText, \@requires )

=cut

sub generateHeadText {
    my ( $validationRules, $formName ) = @_;

    $formName ||= '';

    my @rules    = ();
    my @messages = ();
    my @requires = ();
    push @requires,
      $Foswiki::Plugins::FormPlugin::Constants::TEMPLATE_INLINE_VALIDATION_REQUIRES_DEFAULT;

    while ( my ( $fieldName, $validationRule ) = each( %{$validationRules} ) ) {

        if ( $validationRule->hasRules() ) {
            push( @rules, $validationRule->fieldRulesAsJson() );
        }
        if ( $validationRule->hasMessages() ) {
            push( @messages, $validationRule->fieldMessagesAsJson() );
        }

        #dependencies
        if ( $validationRule->hasRules() ) {

            # wikiword dependency
            if ( $validationRule->{instruction}->{rules}->{wikiword} ) {
                my $tmpl = Foswiki::Func::expandTemplate(
                    'formplugin:javascript:inlinevalidation:requires:wikiword');
                push @requires, $tmpl;
            }
        }
    }

    my $headText =
      $Foswiki::Plugins::FormPlugin::Constants::TEMPLATE_INLINE_VALIDATION;

    my $rulesText    = '{' . join( ',', @rules ) . '}';
    my $messagesText = '{' . join( ',', @messages ) . '}';
    $headText =~ s/%FP_RULES%/$rulesText/;
    $headText =~ s/%FP_MESSAGES%/$messagesText/;
    $headText =~ s/%FP_FORMNAME%/$formName/gos;

    $headText = Foswiki::Func::expandCommonVariables($headText);
    return ( $headText, \@requires );
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
