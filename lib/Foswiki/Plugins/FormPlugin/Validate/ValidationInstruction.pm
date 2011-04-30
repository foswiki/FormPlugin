# See bottom of file for license and copyright information

package Foswiki::Plugins::FormPlugin::Validate::ValidationInstruction;

use strict;
use warnings;

use Error qw(:try);
use JSON -support_by_pp;

my $JSON_TEMPLATE = 'rules : {
	RULES
},
	messages: {
	MESSAGES
}';

my $JSON_TEMPLATE_RULE    = 'RULE_NAME : VALUE';
my $JSON_TEMPLATE_MESSAGE = 'RULE_NAME : MESSAGE';

=pod

This class reads JSON instructions for validation rules and messages and converts them to Perl objects.

=cut

sub new {
    my ( $class, $fieldName, $instructionText ) = @_;
    my $this = {};

    $this->{fieldName} = $fieldName;

    my $instruction =
      _parseInstructionToPerlObject( $fieldName, $instructionText );
    $this->{instruction} = $instruction;
    $this->{params}      = _parseParams($instruction);

    bless $this, $class;
}

=pod

_parseInstructionToPerlObject ( $instructionText, $fieldName ) -> $obj

=cut

sub _parseInstructionToPerlObject {
    my ( $fieldName, $instructionText ) = @_;

    $instructionText = _shorthandMapping($instructionText);

    my $json =
      JSON->new->allow_barekey->allow_singlequote->allow_nonref->pretty;
    my $instruction;    # hashref

    use Text::Balanced qw ( extract_bracketed );
    my ( $userInstruction, $remainder ) =
      extract_bracketed( $instructionText, '{}' );
    $userInstruction = "{$remainder}" if !$userInstruction;

    try {
        $instruction = $json->decode($userInstruction);
    }
    catch Error with {
        my $e = shift;
        Foswiki::Func::writeDebug( "JSON ", $e, " had a problem" );
    };

    return $instruction;
}

sub _shorthandMapping {
    my ($instructionText) = @_;

# legacy: convert FormPlugin 1.x notation for validate param to 2.x JSON notation.
    return _substituteShorthand('required')
      if ( $instructionText eq 'on' );
    return _substituteShorthand('required')
      if ( $instructionText eq 'nonempty' );
    return _substituteShorthand('required') if ( $instructionText eq 'string' );
    return _substituteShorthand('required,integer')
      if ( $instructionText eq 'int' );
    return _substituteShorthand('required,number')
      if ( $instructionText eq 'number' );
    return _substituteShorthand('required,number')
      if ( $instructionText eq 'float' );
    return _substituteShorthand('required,email')
      if ( $instructionText eq 'email' );

    # shorthand: substitute all single words
    if ( $instructionText !~ m/\:/ ) {
        return _substituteShorthand($instructionText);
    }

    return $instructionText;
}

sub _substituteShorthand {
    my ($instructionText) = @_;

    my $json = $JSON_TEMPLATE;

    my @rules    = ();
    my @messages = ();

    my @instructions = split( /\s*,\s*/, $instructionText );
    foreach my $instruction (@instructions) {
        my ( $iRules, $iMessages ) =
          _substituteShorthandInstruction($instruction);
        push @rules,    @{$iRules};
        push @messages, @{$iMessages};
    }

    my $rulesText    = join ",\n", @rules;
    my $messagesText = join ",\n", @messages;

    $json =~ s/RULES/$rulesText/;
    $json =~ s/MESSAGES/$messagesText/;

    return $json;
}

sub _substituteShorthandInstruction {
    my ($instructionText) = @_;

    my @rules    = ();
    my @messages = ();

    if ( $instructionText =~ m/^(\w+)\=?(.*)?$/ ) {
        push @rules, _substituteShorthandRule( $1, $2 );
        push @messages, _substituteShorthandMessage( $1, $2 );
    }

    return ( \@rules, \@messages );
}

sub _substituteShorthandRule {
    my ( $rule, $value ) = @_;

    $value ||= 'true';

    my $json = $JSON_TEMPLATE_RULE;
    $json =~ s/RULE_NAME/$rule/g;
    $json =~ s/VALUE/$value/g;
    return $json;
}

sub _substituteShorthandMessage {
    my ( $rule, $value ) = @_;

    my $json = $JSON_TEMPLATE_MESSAGE;
    $json =~ s/RULE_NAME/$rule/g;

    $value ||= '';
    my $message = parseMessage( $rule, $value );
    $json =~
s/MESSAGE/'$Foswiki::Plugins::FormPlugin::Constants::ERROR_MESSAGES->{$rule}'/g;

    return $json;
}

=pod

parseMessage( $ruleName, \@$messageArgs) -> $messageText

=cut

sub parseMessage {
    my $ruleName = shift;
    my @values   = @_;

    my $message =
      $Foswiki::Plugins::FormPlugin::Constants::ERROR_MESSAGES->{$ruleName};

    my $substitute = sub {
        my ($num) = @_;
        return $values[$num];
    };
    $message =~ s/\{([0-9]+)\}/&$substitute($1)/ges;

    return $message;
}

=pod

_parseParams( $obj ) -> \%values

=cut

sub _parseParams {
    my ($instruction) = @_;

    my $rules = $instruction->{rules};
    return undef if !$rules;

    my $params = {};
    my $json   = JSON->new->allow_barekey->allow_nonref;
    foreach my $name ( keys %{$rules} ) {
        my $rawValue = $rules->{$name};
        my $value;
        if ( JSON::is_bool($rawValue) ) {
            if ( $json->encode($rawValue) eq 'true' ) {
                $value = 1;
            }
            else {
                $value = 0;
            }
        }
        else {
            $value = $json->encode($rawValue);
        }

        # remove quotes
        $value =~ s/^\"?(.*?)\"?$/$1/;
        $params->{$name} = $value;
    }
    return $params;

}

sub hasRules {
    my ($this) = @_;

    return defined $this->{instruction}->{rules};
}

sub hasMessages {
    my ($this) = @_;

    return defined $this->{instruction}->{messages};
}

sub fieldRulesAsJson {
    my ($this) = @_;

    return _formatAsJson( $this->{fieldName}, $this->{instruction}->{rules} );
}

sub fieldMessagesAsJson {
    my ($this) = @_;

    return _formatAsJson( $this->{fieldName},
        $this->{instruction}->{messages} );
}

sub _formatAsJson {
    my ( $fieldName, $obj ) = @_;

    return '' if !defined $obj;

    my $o = { "$fieldName" => $obj };

    my $json =
      JSON->new->allow_barekey->allow_singlequote->allow_nonref->pretty;
    my $formatted = $json->encode($o);

    my $str = '' . $formatted;
    $str =~ s/^\s*\{(.*?)\}\s*$/$1/s;
    return $str;
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
