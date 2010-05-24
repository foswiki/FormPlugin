use strict;

package FormPluginTests;

use FoswikiFnTestCase;
our @ISA = qw( FoswikiFnTestCase );

use strict;
use warnings;
use Error qw( :try );

use Foswiki::Func;
use Data::Dumper;    # for debugging
use HTML::Form;
use LWP::UserAgent;
use HTTP::Request;

my $DEBUG = 0;
my $query;

sub new {
    my $self = shift()->SUPER::new( 'FormPluginFunctions', @_ );
    return $self;
}

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();
	$this->{session}->finish();
	
	$query = new Unit::Request;
	
    $this->_setPathInfoToTopic( 'view', $this->{test_web},
        $this->{test_topic} );

    # to make the received topic text less cluttered
    $this->_setWebPref( "SKIN", "text" );
}

sub _setPathInfoToTopic {
    my ( $this, $script, $web, $topic ) = @_;

    $query->path_info( "$script/" . $web . '/' . $topic );
    $this->{session}->finish() if ( defined( $this->{session} ) );
    $this->{session} = new Foswiki( undef, $query );
    $Foswiki::Plugins::SESSION = $this->{session};
}

sub loadExtraConfig {
    my $this = shift;
    $this->SUPER::loadExtraConfig();
    setLocalSite();
}

sub setLocalSite {
    $Foswiki::cfg{Plugins}{FormPlugin}{Enabled} = 1;
    $Foswiki::cfg{Plugins}{FormPlugin}{Debug}   = $DEBUG;
    $Foswiki::cfg{AllowRedirectUrl} = 0;
	$Foswiki::cfg{PermittedRedirectHostUrls} = '';
}

#sub tear_down {
#    my $this = shift;
#}

=pod

FORMELEMENT type="text"

=cut

sub test_formelement_type_text {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="comment" 
type="text" 
title="Comment" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementcomment"><!--//--></a>
<p> <span class="formPluginTitle">Comment</span> <br /> <noautolink><input type="text" name="comment" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="textonly"

=cut

sub test_formelement_type_textonly {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="name" 
type="textonly" 
value="%TOPIC%" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementname"><!--//--></a>
<p> <noautolink><span class="formPluginTextOnly">$this->{test_topic}</span><input type="hidden" name="name" value="$this->{test_topic}" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="password"

=cut

sub test_formelement_type_password {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="pw" 
type="password" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementpw"><!--//--></a>
<p> <noautolink><input type="password" name="pw" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="upload"

=cut

sub test_formelement_type_upload {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
type="upload" 
name="filepath" 
title="Attach profile picture" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementfilepath"><!--//--></a>
<p> <span class="formPluginTitle">Attach profile picture</span> <br /> <noautolink><input type="file" name="filepath" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="textarea"

=cut

sub test_formelement_type_textarea {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="body" 
type="textarea"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementbody"><!--//--></a>
<p> <noautolink><textarea name="body" tabindex="1"  class="foswikiInputField"></textarea></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="select"

=cut

sub test_formelement_type_select {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="friend" 
type="select" 
size="5" 
title="Select friend:" 
options="mary, peter, annabel, nicky, jennifer" 
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementfriend"><!--//--></a>
<p> <span class="formPluginTitle">Select friend:</span> <br /> <noautolink><select name="friend" tabindex="1"  size="5" class="foswikiSelect">
<option value="mary">Mary M</option>
<option value="peter">Peter P</option>
<option value="annabel">Annabel A</option>
<option value="nicky">Nicky N</option>
<option value="jennifer">Jennifer J</option>
</select></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="select" with value of 0

=cut

sub test_formelement_type_select_value_0 {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="friend" 
type="select" 
size="5" 
title="Select friend:" 
options="0, 1, 2, 3, 4" 
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J" 
value="0"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementfriend"><!--//--></a>
<p> <span class="formPluginTitle">Select friend:</span> <br /> <noautolink><select name="friend" tabindex="1"  size="5" class="foswikiSelect">
<option selected="selected" value="0">Mary M</option>
<option value="1">Peter P</option>
<option value="2">Annabel A</option>
<option value="3">Nicky N</option>
<option value="4">Jennifer J</option>
</select></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="selectmulti"

=cut

sub test_formelement_type_selectmulti {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="friends" 
type="selectmulti" 
size="5" 
title="Select friends:" 
options="mary, peter, annabel, nicky, jennifer" 
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J" 
value="mary,annabel" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementfriends"><!--//--></a>
<p> <span class="formPluginTitle">Select friends:</span> <br /> <noautolink><select name="friends" tabindex="1"  size="5" multiple="multiple" class="foswikiSelect">
<option selected="selected" value="mary">Mary M</option>
<option value="peter">Peter P</option>
<option selected="selected" value="annabel">Annabel A</option>
<option value="nicky">Nicky N</option>
<option value="jennifer">Jennifer J</option>
</select></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="dropdown"

=cut

sub test_formelement_type_dropdown {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="friend" 
type="dropdown" 
title="Select friend:" 
options="mary, peter, annabel, nicky, jennifer" 
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J" 
value="peter" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementfriend"><!--//--></a>
<p> <span class="formPluginTitle">Select friend:</span> <br /> <noautolink><select name="friend" tabindex="1"  size="1" class="foswikiSelect">
<option value="mary">Mary M</option>
<option selected="selected" value="peter">Peter P</option>
<option value="annabel">Annabel A</option>
<option value="nicky">Nicky N</option>
<option value="jennifer">Jennifer J</option>
</select></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="checkbox"

=cut

sub test_formelement_type_checkbox {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="name" 
type="checkbox" 
options="mary, peter, annabel, nicky, jennifer"
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J"
value="mary,peter" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementname"><!--//--></a>
<p> <noautolink><fieldset class="formPluginGroup"><input id="name_mary" name="name" type="checkbox" value="mary" checked="1" class="foswikiCheckbox" /><label for="name_mary">Mary M</label> <input id="name_peter" name="name" type="checkbox" value="peter" checked="1" class="foswikiCheckbox" /><label for="name_peter">Peter P</label> <input id="name_annabel" name="name" type="checkbox" value="annabel" class="foswikiCheckbox" /><label for="name_annabel">Annabel A</label> <input id="name_nicky" name="name" type="checkbox" value="nicky" class="foswikiCheckbox" /><label for="name_nicky">Nicky N</label> <input id="name_jennifer" name="name" type="checkbox" value="jennifer" class="foswikiCheckbox" /><label for="name_jennifer">Jennifer J</label></fieldset></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="radio"

=cut

sub test_formelement_type_radio {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="name" 
type="radio" 
options="mary, peter, annabel, nicky, jennifer"
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J" 
value="mary" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementname"><!--//--></a>
<p> <noautolink><fieldset class="formPluginGroup"><input id="name_mary" name="name" type="radio" value="mary" checked="1" class="foswikiRadioButton" /><label for="name_mary">Mary M</label> <input id="name_peter" name="name" type="radio" value="peter" class="foswikiRadioButton" /><label for="name_peter">Peter P</label> <input id="name_annabel" name="name" type="radio" value="annabel" class="foswikiRadioButton" /><label for="name_annabel">Annabel A</label> <input id="name_nicky" name="name" type="radio" value="nicky" class="foswikiRadioButton" /><label for="name_nicky">Nicky N</label> <input id="name_jennifer" name="name" type="radio" value="jennifer" class="foswikiRadioButton" /><label for="name_jennifer">Jennifer J</label></fieldset></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="date"

=cut

sub test_formelement_type_date {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="date" 
type="date"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementdate"><!--//--></a>
<p> <noautolink><input type="text" name="date" tabindex="1"  size="15" class="foswikiInputField" id="caldate" /> <span class="foswikiMakeVisible"><input type="image" name="calendar" src="/~arthur/unittestfoswiki/core/pub/System/JSCalendarContrib/img.gif" align="middle" alt="Calendar" onclick="return showCalendar('caldate','%e %b %Y')" class="editTableCalendarButton" /></span></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="submit"

=cut

sub test_formelement_type_submit {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="action" 
type="submit" 
value="Send info" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementaction"><!--//--></a>
<p> <noautolink><input type="submit" tabindex="1" name="action" value="Send info" class="foswikiSubmit" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="hidden"

=cut

sub test_formelement_type_hidden {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="CarbonCopy" 
type="hidden" 
default="$Name earns $Salary" 
}%';

    my $expected = <<END_EXPECTED;
<noautolink><input type="hidden" name="CarbonCopy" value="\$Name earns \$Salary" /></noautolink>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT options="..." - DataForm notation

=cut

sub test_formelement_options_dataform_notation {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="name" 
type="checkbox" 
title="Choose a name:" 
options="mary=Mary M, peter=Peter P, annabel=Annabel A, nicky=Nicky N, jennifer=Jennifer J" 
value="mary,peter" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementname"><!--//--></a>
<p> <span class="formPluginTitle">Choose a name:</span> <br /> <noautolink><fieldset class="formPluginGroup"><input id="name_mary" name="name" type="checkbox" value="mary" checked="1" class="foswikiCheckbox" /><label for="name_mary">Mary M</label> <input id="name_peter" name="name" type="checkbox" value="peter" checked="1" class="foswikiCheckbox" /><label for="name_peter">Peter P</label> <input id="name_annabel" name="name" type="checkbox" value="annabel" class="foswikiCheckbox" /><label for="name_annabel">Annabel A</label> <input id="name_nicky" name="name" type="checkbox" value="nicky" class="foswikiCheckbox" /><label for="name_nicky">Nicky N</label> <input id="name_jennifer" name="name" type="checkbox" value="jennifer" class="foswikiCheckbox" /><label for="name_jennifer">Jennifer J</label></fieldset></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT buttonlabel

=cut

sub test_formelement_buttonlabel {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="action" 
type="submit" 
buttonlabel="Send info" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementaction"><!--//--></a>
<p> <noautolink><input type="submit" tabindex="1" name="action" value="Send info" class="foswikiSubmit" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT hint

=cut

sub test_formelement_hint {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="comment" 
type="text" 
title="Comment" 
hint="anything"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementcomment"><!--//--></a>
<p> <span class="formPluginTitle">Comment</span> <br /> <noautolink><input type="text" name="comment" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>  <span class="formPluginHint">anything</span> </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT mandatory="on"

=cut

sub test_formelement_mandatory {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="comment" 
type="text" 
mandatory="on"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementcomment"><!--//--></a>
<p> <noautolink><input type="text" name="comment" tabindex="1"  size="40" class="foswikiInputField" /></noautolink> <span class="formPluginMandatory">*</span>  </p>
<input type="hidden" name="FP_validate_comment" value="comment=s" />
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT format

=cut

sub test_formelement_format {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="comment" 
type="text" 
title="Comment" 
hint="anything"
mandatory="on"
format="   * $a
   * m
   * h
   * $e
   * $t"
}%';

    my $expected = <<END_EXPECTED;
   * <a name="FormElementcomment"><!--//--></a>
   * m
   * h
   * <noautolink><input type="text" name="comment" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>
   * <span class="formPluginTitle">Comment</span>
<input type="hidden" name="FP_validate_comment" value="comment=s" />
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT fieldformat

=cut

sub test_formelement_fieldformat {
    my ($this) = @_;

    my $input = '%FORMELEMENT{
name="friends"
type="radio"
options="mary=Mary M, peter=Peter P, annabel=Annabel A, nicky=Nicky N, jennifer=Jennifer J"
fieldformat="$e <br />"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementfriends"><!--//--></a>
<p> <noautolink><fieldset class="formPluginGroup"><input id="friends_mary" name="friends" type="radio" value="mary" class="foswikiRadioButton" /><label for="friends_mary">Mary M</label> <br /> <input id="friends_peter" name="friends" type="radio" value="peter" class="foswikiRadioButton" /><label for="friends_peter">Peter P</label> <br /> <input id="friends_annabel" name="friends" type="radio" value="annabel" class="foswikiRadioButton" /><label for="friends_annabel">Annabel A</label> <br /> <input id="friends_nicky" name="friends" type="radio" value="nicky" class="foswikiRadioButton" /><label for="friends_nicky">Nicky N</label> <br /> <input id="friends_jennifer" name="friends" type="radio" value="jennifer" class="foswikiRadioButton" /><label for="friends_jennifer">Jennifer J</label> <br /></fieldset></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT titleformat

=cut

sub test_formelement_titleformat {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="comment" 
type="text" 
title="Comment" 
titleformat=" *$t* <br />"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementcomment"><!--//--></a>
<p> *<span class="formPluginTitle">Comment</span>* <br /> <noautolink><input type="text" name="comment" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT cssclass

=cut

sub test_formelement_cssclass {
    my ($this) = @_;

    my $input = '%FORMELEMENT{
name="Name"
type="text"
cssclass="foswikiBroadcastMessage"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementName"><!--//--></a>
<p> <noautolink><input type="text" name="Name" tabindex="1"  size="40" class="foswikiBroadcastMessage" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT size

=cut

sub test_formelement_size {
    my ($this) = @_;

    my $input = '%FORMELEMENT{
name="Name"
type="text"
size="80"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementName"><!--//--></a>
<p> <noautolink><input type="text" name="Name" tabindex="1"  size="80" class="foswikiInputField" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT maxlength

=cut

sub test_formelement_maxlength {
    my ($this) = @_;

    my $input = '%FORMELEMENT{
name="Name"
type="text"
maxlength="80"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementName"><!--//--></a>
<p> <noautolink><input type="text" name="Name" tabindex="1"  size="40" maxlength="80" class="foswikiInputField" /></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT rows, cols

=cut

sub test_formelement_rows_cols {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="body" 
type="textarea" 
title="Message:" 
rows="5" 
cols="80" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementbody"><!--//--></a>
<p> <span class="formPluginTitle">Message:</span> <br /> <noautolink><textarea name="body" tabindex="1"  rows="5" cols="80" class="foswikiInputField"></textarea></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT focus

=cut

sub test_formelement_focus {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="name" 
type="text"  
focus="on"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementname"><!--//--></a>
<p> <noautolink><input type="text" name="name" tabindex="1"  size="40" class="foswikiInputField" /></noautolink><script type="text/javascript">foswiki.Form.setFocus("", "name");</script>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT disabled

=cut

sub test_formelement_disabled {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="name" 
type="text"  
disabled="on"
}%
%FORMELEMENT{ 
name="friends" 
type="checkbox" 
options="mary, peter, annabel, nicky, jennifer"
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J"
disabled="on"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementname"><!--//--></a>
<p> <noautolink><input type="text" name="name" tabindex="1"  size="40" disabled="disabled" class="foswikiInputFieldDisabled" /></noautolink>   </p>
<a name="FormElementfriends"><!--//--></a>
<p> <noautolink><fieldset class="formPluginGroup"><input id="friends_mary" name="friends" type="checkbox" value="mary" disabled="disabled" class="foswikiCheckbox" /><label for="friends_mary">Mary M</label> <input id="friends_peter" name="friends" type="checkbox" value="peter" disabled="disabled" class="foswikiCheckbox" /><label for="friends_peter">Peter P</label> <input id="friends_annabel" name="friends" type="checkbox" value="annabel" disabled="disabled" class="foswikiCheckbox" /><label for="friends_annabel">Annabel A</label> <input id="friends_nicky" name="friends" type="checkbox" value="nicky" disabled="disabled" class="foswikiCheckbox" /><label for="friends_nicky">Nicky N</label> <input id="friends_jennifer" name="friends" type="checkbox" value="jennifer" disabled="disabled" class="foswikiCheckbox" /><label for="friends_jennifer">Jennifer J</label></fieldset></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT readonly

=cut

sub test_formelement_readonly {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="name" 
type="text"  
readonly="on"
value="heh"
}%
%FORMELEMENT{ 
name="text" 
type="textarea"  
readonly="on"
value="mo"
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementname"><!--//--></a>
<p> <noautolink><input type="text" name="name" tabindex="1" value="heh" size="40" readonly="readonly" class="foswikiInputFieldReadOnly" /></noautolink>   </p>
<a name="FormElementtext"><!--//--></a>
<p> <noautolink><textarea name="text" tabindex="2"  readonly="readonly" class="foswikiInputFieldReadOnly">mo</textarea></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

FORMELEMENT type="dateformat"

=cut

sub test_formelement_type_dateformat {
    my ($this) = @_;

    my $input = '%FORMELEMENT{ 
name="date" 
type="date" 
dateformat="%e-%b-%y" 
}%';

    my $expected = <<END_EXPECTED;
<a name="FormElementdate"><!--//--></a>
<p> <noautolink><input type="text" name="date" tabindex="1"  size="15" class="foswikiInputField" id="caldate" /> <span class="foswikiMakeVisible"><input type="image" name="calendar" src="/~arthur/unittestfoswiki/core/pub/System/JSCalendarContrib/img.gif" align="middle" alt="Calendar" onclick="return showCalendar('caldate','%e-%b-%y')" class="editTableCalendarButton" /></span></noautolink>   </p>
END_EXPECTED

	_trimSpaces($input);
	_trimSpaces($expected);
	
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_simple_form {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = 'BEFORE
%STARTFORM{
name="myform"
action="view"
}%
%ENDFORM%
AFTER';

    my $expected = <<END_EXPECTED;
BEFORE
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
AFTER
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_form_no_name_no_action {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<div class="foswikiAlert"><strong><nop>FormPlugin error:</strong> parameters =name= and =action= are required for =STARTFORM=.</div>
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_form_no_name {
    my ($this) = @_;

    my $input = '%STARTFORM{
action="view"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<div class="foswikiAlert"><strong><nop>FormPlugin error:</strong> parameter =name= is required for =STARTFORM= (missing at form with action: =view=).</div>
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_script_manage {
    my ($this) = @_;

    my $viewScriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
    my $manageScriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'manage' );

    my $input = 'BEFORE
%STARTFORM{
name="myform"
action="manage"
}%
%ENDFORM%
AFTER';

    my $expected = <<END_EXPECTED;
BEFORE
<!--FormPlugin form start--><form method="post" action="$viewScriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$manageScriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
AFTER
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_form_no_action {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<div class="foswikiAlert"><strong><nop>FormPlugin error:</strong> parameter =action= is required for =STARTFORM= (missing at form with name: =myform=).</div>
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_action_custom {
    my ($this) = @_;

    my $viewUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $attachUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'attach' );

    my $input = '%STARTFORM{
name="myform"
action="%SCRIPTURL{attach}%' . '/'
      . $this->{test_web} . '/'
      . $this->{test_topic} . '"' . '
}%
%ENDFORM%';

    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$viewUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div><input type="hidden" name="FP_actionurl" value="$attachUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    $input =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_id {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
id="glow in the dark"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="glow in the dark">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_topic {
    my ($this) = @_;

    my $topic = 'WebHome';
    $this->_setPathInfoToTopic( 'view', $this->{test_web}, $topic );

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
topic="' . $topic . '"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );

    $this->_setPathInfoToTopic( 'view', $this->{test_web},
        $this->{test_topic} );
}

=pod

=cut

sub test_startform_param_web {
    my ($this) = @_;

    my $web = 'MyWeb';
    $this->_setPathInfoToTopic( 'view', $web, $this->{test_topic} );

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $web, $this->{test_topic}, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
web="' . $web . '"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );

    $this->_setPathInfoToTopic( 'view', $this->{test_web},
        $this->{test_topic} );
}

=pod

=cut

sub test_startform_param_anchor {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
anchor="StartHere"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#StartHere" enctype="multipart/form-data" name="myform" id="myform">
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<input type="hidden" name="FP_anchor" value="StartHere" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_post_startform_param_anchor {
    my ($this) = @_;

    my $anchor = 'StartHere';
    my $input  = '%STARTFORM{
name="myform"
action="view"
anchor="StartHere"
}%
%FORMELEMENT{
type="submit"
name="submit"
value="Submit"
}%
%ENDFORM%';

    my $testTopicUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $response = $this->_submitForm($input);
    $this->assert_equals( '200', $response->code );
}

=pod

=cut

sub test_startform_param_method_post {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
method="POST"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_method_get {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
method="GET"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="get" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_method_empty {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
method=""
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_redirectto {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
    my $redirectScriptUrl =
      Foswiki::Func::getScriptUrl( 'System', 'WebHome',
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
redirectto="System.WebHome"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<input type="hidden" name="redirectto" value="$redirectScriptUrl" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_post_startform_param_redirectto {
    my ($this) = @_;

	my $redirectWeb = 'Main';
	my $redirectTopic = 'WebHome';
	
    my $input = '%STARTFORM{
name="myform"
action="view"
method="post"
redirectto="' . $redirectWeb . '.' . $redirectTopic . '"
}%
%FORMELEMENT{
name="text"
type="hidden"
value="qwerty123"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm($input);

    # we cannot test the actual redirected to topic, but we should see a 307 status
    $this->assert_equals( '307', $response->code );
    
    my $location = $response->header('location');
    _removeFoswikiRedirectCache($location);
    
    my $expected = Foswiki::Func::getScriptUrl( $redirectWeb, $redirectTopic, 'view' );
    $this->assert_equals( $expected, $location );
}

=pod

=cut

sub test_startform_param_formcssclass {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
formcssclass="foswikiFormSteps"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div class="foswikiFormSteps">
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_elementcssclass {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
formcssclass="foswikiFormSteps"
elementcssclass="foswikiFormStep"
}%
%FORMELEMENT{
name="Name"
type="text"
title="Enter your name:"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div class="foswikiFormSteps">
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<div class="foswikiFormStep"><p> <span class="formPluginTitle">Enter your name:</span> <br /> <noautolink><input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p></div>
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_noformhtml {
    my ($this) = @_;

    my $input = '%STARTFORM{
noformhtml="on"
}%
%FORMELEMENT{
name="Name"
type="text"
title="Enter your name:"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<a name="FormElementName"><!--//--></a>
<p> <span class="formPluginTitle">Enter your name:</span> <br /> <noautolink><input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p>
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_onSubmit {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
onSubmit="return notify(this)"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" onsubmit="return notify(this)" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_sep_nospace {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
sep=""
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_sep_with_table {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
sep=""
}%
| %FORMELEMENT{
name="Name"
type="text"
title="Enter your name:"
}% |
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform"><div><input type="hidden" name="FP_actionurl" value="$scriptUrl"  /><input type="hidden" name="FP_name" value="myform" />
| <a name="FormElementName"><!--//--></a><p> <span class="formPluginTitle">Enter your name:</span> <br /> <noautolink><input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p> |
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_validate {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
mandatory="on"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform">
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<p> <noautolink><input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" /></noautolink> <span class="formPluginMandatory">*</span>  </p>
<input type="hidden" name="FP_validate_Name" value="Name=s" />
<a name="FormElementaction"><!--//--></a>
<p> <noautolink><input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" /></noautolink>   </p>
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result =
      Foswiki::Func::expandCommonVariables( $input, $this->{test_topic},
        $this->{test_web} );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_validate_off {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="off"
}%
%FORMELEMENT{
name="Name"
type="text"
value=""
validate="nonempty"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
	my $result = $response->content;
	
	_removeValidationKey($result);
    
    my $expected = <<EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="http://localhost/~arthur/unittestfoswiki/core/bin/view/TemporaryFormPluginFunctionsTestWebFormPluginFunctions/TestTopicFormPluginFunctions" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<p> <input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" />   </p>
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod

=cut

sub test_post_startform_param_off {
    my ($this) = @_;
    
    my $redirectTopic = 'WebHome';

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $redirectTopic,
        'view' );
    
    my $input = '%STARTFORM{
name="x"
action="view"
topic="' . $redirectTopic . '"
noredirect="off"
}%
%FORMELEMENT{
name="action"
type="submit"
buttonlabel="Submit"
}%
%ENDFORM%';
    
    my $response = $this->_submitForm( $input );
    my $location = $response->header('location');
    _removeFoswikiRedirectCache($location);
    
    my $expected = $scriptUrl;
	
    $this->assert_str_equals( $expected, $location, 0 );
}

=pod

=cut

sub test_post_startform_param_noredirect_on {
    my ($this) = @_;
    
    my $redirectTopic = 'WebHome';

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
    my $scriptUrlRedirectTopic =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $redirectTopic,
        'view' );
    
    my $input = '%STARTFORM{
name="x"
action="view"
topic="' . $redirectTopic . '"
noredirect="on"
}%
%FORMELEMENT{
name="action"
type="submit"
buttonlabel="Submit"
}%
%ENDFORM%';
    
    my $response = $this->_submitForm( $input );
    my $result = $response->content;
    _removeValidationKey($result);
    
    my $expected = <<EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="x" id="x" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrlRedirectTopic" />
<input type="hidden" name="FP_noredirect" value="1" />
<input type="hidden" name="FP_name" value="x" />
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="1" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}
=pod

STARTFORM: validate="on"
FORMELEMENT: validate="nonempty" => invalid value

=cut

sub test_post_formelement_param_validate_nonempty_error {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value=""
validate="nonempty"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $expected             = <<END_EXPECTED;
<a name="FormPluginNotification"><!--//--></a><div class="formPluginError formPluginNotification"><span class="formPluginTitle">Some required information is missing or incomplete:</span><span class="formPluginErrorItem"><a href="$scriptUrl#FormElementName">Name</a> - please enter a value</span></div>
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<div class="formPluginError"><p> <input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" />   </p>
<input type="hidden" name="FP_validate_Name" value="Name=s" /></div>
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
END_EXPECTED

    my $response = $this->_submitForm( $input );
	$this->assert_matches( qr/^200/, $response->code() );

    my $result = $response->content;

    _removeValidationKey($result);

    _trimSpaces($expected);
    _trimSpaces($result);

    _debug("EXP=$expected");
    _debug("RES=$result");
    
    $this->assert_str_equals( $expected, $result );
}

=pod

Same as previous test, now suppressing the error feedback

=cut

sub test_post_formelement_param_validate_nonempty_error_showerrors_off {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
showerrors="off"
}%
%FORMELEMENT{
name="Name"
type="text"
value=""
validate="nonempty"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $expected             = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<div class="formPluginError"><p> <input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" />   </p>
<input type="hidden" name="FP_validate_Name" value="Name=s" /></div>
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
END_EXPECTED

    my $response = $this->_submitForm( $input );
	$this->assert_matches( qr/^200/, $response->code() );

    my $result = $response->content;

    _removeValidationKey($result);

    _trimSpaces($expected);
    _trimSpaces($result);

    _debug("EXP=$expected");
    _debug("RES=$result");
    
    $this->assert_str_equals( $expected, $result );
}

=pod

Same as previous test, now putting the errors below

=cut

sub test_post_formelement_param_validate_nonempty_error_showerrors_below {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
showerrors="below"
}%
%FORMELEMENT{
name="Name"
type="text"
value=""
validate="nonempty"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $expected             = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<div class="formPluginError"><p> <input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" />   </p>
<input type="hidden" name="FP_validate_Name" value="Name=s" /></div>
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
<a name="FormPluginNotification"><!--//--></a><div class="formPluginError formPluginNotification"><span class="formPluginTitle">Some required information is missing or incomplete:</span><span class="formPluginErrorItem"><a href="$scriptUrl#FormElementName">Name</a> - please enter a value</span></div>
END_EXPECTED

    my $response = $this->_submitForm( $input );
	$this->assert_matches( qr/^200/, $response->code() );

    my $result = $response->content;

    _removeValidationKey($result);

    _trimSpaces($expected);
    _trimSpaces($result);

    _debug("EXP=$expected");
    _debug("RES=$result");
    
    $this->assert_str_equals( $expected, $result );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="nonempty" => valid value

=cut

sub test_post_formelement_param_validate_nonempty_ok {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, 'WebHome',
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
redirectto="' . $this->{test_web} . '.WebHome"
}%
%FORMELEMENT{
name="Name"
type="text"
value="bla"
validate="nonempty"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
	$this->assert_matches( qr/^307/, $response->code() );

    my $location = $response->header('location') || '';
	_removeFoswikiRedirectCache($location);

	_debug("EXP=$scriptUrl");
    _debug("RES=$location");
    
    $this->assert_str_equals( $scriptUrl, $location );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="string" => invalid value (empty)

=cut

sub test_post_formelement_param_validate_string_error {
    my ($this) = @_;
      
    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value=""
validate="string"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
	$this->assert_matches( qr/^200/, $response->code() );
}

=pod

As previous test, now test correct error message

=cut

sub test_post_formelement_param_validate_string_error_message {
    my ($this) = @_;
      
    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
      
    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value=""
validate="string"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
	my $result = $response->content;
	_removeValidationKey($result);
	
    my $expected = <<EXPECTED;
<a name="FormPluginNotification"><!--//--></a><div class="formPluginError formPluginNotification"><span class="formPluginTitle">Some required information is missing or incomplete:</span><span class="formPluginErrorItem"><a href="$scriptUrl#FormElementName">Name</a> - please enter a value</span></div>
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<div class="formPluginError"><p> <input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" />   </p>
<input type="hidden" name="FP_validate_Name" value="Name=s" /></div>
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="string" => valid value

=cut

sub test_post_formelement_param_validate_string_ok {
    my ($this) = @_;

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="bla"
validate="string"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
    $this->assert_matches( qr/^200/, $response->code() );
}

=pod

Tests redirectto location with valid input


=cut

sub test_post_formelement_param_validate_string_ok_location {
    my ($this) = @_;

    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, 'WebHome',
        'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
redirectto="' . $this->{test_web} . '.WebHome"
}%
%FORMELEMENT{
name="Name"
type="text"
value="bla"
validate="string"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );    
    my $location = $response->header('location') || '';
	_removeFoswikiRedirectCache($location);

	_debug("EXP=$scriptUrl");
    _debug("RES=$location");
    
    $this->assert_str_equals( $scriptUrl, $location );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="int" => invalid value

=cut

sub test_post_formelement_param_validate_int_error {
    my ($this) = @_;

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="bla"
validate="int"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
    $this->assert_matches( qr/^200/, $response->code() );
}

=pod

As previous test, now test correct error message

=cut

sub test_post_formelement_param_validate_int_error_message {
    my ($this) = @_;
      
    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
      
    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="bla"
validate="int"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
	my $result = $response->content;
	_removeValidationKey($result);
	
    my $expected = <<EXPECTED;
<a name="FormPluginNotification"><!--//--></a><div class="formPluginError formPluginNotification"><span class="formPluginTitle">Some required information is missing or incomplete:</span><span class="formPluginErrorItem"><a href="$scriptUrl#FormElementName">Name</a> - enter a different value (a rounded number, like '2')</span></div>
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<div class="formPluginError"><p> <input type="text" name="Name" tabindex="1" value="bla" size="40" class="foswikiInputField" />   </p>
<input type="hidden" name="FP_validate_Name" value="Name=i" /></div>
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="int" => valid value

=cut

sub test_post_formelement_param_validate_int_ok {
    my ($this) = @_;

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
redirectto="' . $this->{test_web} . '.WebHome"
}%
%FORMELEMENT{
name="Name"
type="text"
value="1"
validate="int"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
    $this->assert_matches( qr/^307/, $response->code() );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="float" => invalid value (string)

=cut

sub test_post_formelement_param_validate_float_error {
    my ($this) = @_;

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="bla"
validate="float"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
    $this->assert_matches( qr/^200/, $response->code() );
}

=pod

As previous test, now test correct error message

=cut

sub test_post_formelement_param_validate_float_error_message {
    my ($this) = @_;
      
    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
      
    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="bla"
validate="float"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
	my $result = $response->content;
	_removeValidationKey($result);
	
    my $expected = <<EXPECTED;
<a name="FormPluginNotification"><!--//--></a><div class="formPluginError formPluginNotification"><span class="formPluginTitle">Some required information is missing or incomplete:</span><span class="formPluginErrorItem"><a href="$scriptUrl#FormElementName">Name</a> - enter a different value (a floating number or a rounded number)</span></div>
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<div class="formPluginError"><p> <input type="text" name="Name" tabindex="1" value="bla" size="40" class="foswikiInputField" />   </p>
<input type="hidden" name="FP_validate_Name" value="Name=f" /></div>
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="float" => valid value

=cut

sub test_post_formelement_param_validate_float_ok {
    my ($this) = @_;

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="1.1"
validate="float"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
    $this->assert_matches( qr/^200/, $response->code() );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="email" => invalid value

=cut

sub test_post_formelement_param_validate_email_error {
    my ($this) = @_;

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="zo.com"
validate="email"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
    $this->assert_matches( qr/^200/, $response->code() );
}

=pod

As previous test, now test correct error message

=cut

sub test_post_formelement_param_validate_email_error_message {
    my ($this) = @_;
      
    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
      
    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="zo.com"
validate="email"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
	my $result = $response->content;
	_removeValidationKey($result);
	
    my $expected = <<EXPECTED;
<a name="FormPluginNotification"><!--//--></a><div class="formPluginError formPluginNotification"><span class="formPluginTitle">Some required information is missing or incomplete:</span><span class="formPluginErrorItem"><a href="$scriptUrl#FormElementName">Name</a> - enter a different value (an e-mail address)</span></div>
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="myform" id="myform" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="myform" />
<a name="FormElementName"><!--//--></a>
<div class="formPluginError"><p> <input type="text" name="Name" tabindex="1" value="zo.com" size="40" class="foswikiInputField" />   </p>
<input type="hidden" name="FP_validate_Name" value="Name=e" /></div>
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod

STARTFORM: validate="on"
FORMELEMENT: validate="email" => valid value

=cut

sub test_post_formelement_param_validate_email_ok {
    my ($this) = @_;

    my $input = '%STARTFORM{
name="myform"
action="view"
validate="on"
}%
%FORMELEMENT{
name="Name"
type="text"
value="a@zo.com"
validate="email"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    my $response = $this->_submitForm( $input );
    $this->assert_matches( qr/^200/, $response->code() );
}

=pod

Does not work

=cut

sub __test_post_save {
    my ($this) = @_;

	my $topic = 'NewTestTopic';
	my $web = $this->{test_web};
	
    my $input = '%STARTFORM{
name="myform"
action="save"
topic="' . $topic . '"
}%
%FORMELEMENT{
name="text"
type="hidden"
value="1234567890 qwertyuiop"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

   # ...
}

=pod

Passes 2 multi-input fields.
Uses value substitution in the 3rd field.

=cut

sub test_post_multiple {
    my ($this) = @_;

	my $resultTML = '   * friends = %URLPARAM{"friends" multiple="on" separator=", "}%
	* subject = %URLPARAM{"subject" multiple="on" separator=", "}%
	* together = %URLPARAM{"together" multiple="on" separator=", "}%';
	my $resultTopic = 'MultipleResult';
	Foswiki::Func::saveTopicText( $this->{test_web}, $resultTopic,
	$resultTML );
        
    my $input = '%STARTFORM{
name="multiform"
action="view"
topic="' . $resultTopic . '"
}%
%FORMELEMENT{
name="friends"
type="checkbox"
options="mary, peter, annabel, nicky, jennifer"
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J"
default="mary,peter"
validate="nonempty"
mandatory="on"
hint="Select at least one person"
}%
%FORMELEMENT{
name="subject"
type="selectmulti"
options="work,freetime,not important"
labels="Work, Freetime, Not important"
default="work,not important"
size="3"
validate="nonempty"
mandatory="on"
}%
%FORMELEMENT{
name="together"
type="hidden"
value="$friends"
}%
%FORMELEMENT{
name="action"
type="submit"
buttonlabel="Submit"
}%
%ENDFORM%';

    $this->_setPathInfoToTopic( 'view', $this->{test_web}, $resultTopic );
    
    my $response = $this->_submitForm( $input );
    my $result = $response->content;
    
    my $expected = <<EXPECTED;
<ul>
<li> friends = mary, peter
</li> <li> subject = work, not important
</li> <li> together = mary, peter
</li></ul>
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

sub test_post_radio {
    my ($this) = @_;

	my $resultTML = '   * friends = %URLPARAM{"friends" multiple="on" separator=", "}%
	* together = %URLPARAM{"together" multiple="on" separator=", "}%';
	my $resultTopic = 'MultipleResult';
	Foswiki::Func::saveTopicText( $this->{test_web}, $resultTopic,
	$resultTML );
        
    my $input = '%STARTFORM{
name="multiform"
action="view"
topic="FormPluginExamplesFeedback"
}%
%FORMELEMENT{
name="friends"
type="radio"
options="mary=Mary M, peter=Peter P, annabel=Annabel A, nicky=Nicky N, jennifer=Jennifer J"
validate="nonempty"
fieldformat="$e <br />"
titleformat=" *$t* %BR%"
mandatory="on"
hint="Select one person"
default="annabel"
}%
%FORMELEMENT{
name="together"
type="hidden"
value="$friends"
}%
%FORMELEMENT{
name="action"
type="submit"
buttonlabel="Submit"
}%
%ENDFORM%';

    $this->_setPathInfoToTopic( 'view', $this->{test_web}, $resultTopic );
    
    my $response = $this->_submitForm( $input );
    my $result = $response->content;
    
    my $expected = <<EXPECTED;
<ul>
<li> friends = annabel
</li> <li> together = annabel
</li></ul>
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod

Test condition param with 'valid' input 

=cut

sub test_post_condition_valid {
    my ($this) = @_;
    
    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
        
    my $input = '%STARTFORM{
name="x"
action="view"
}%
%FORMELEMENT{
name="friends"
type="checkbox"
options="mary, peter, annabel, nicky, jennifer"
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J"
default="mary,peter"
hint="Select any person"
}%
%FORMELEMENT{
name="together"
type="hidden"
value="friends: $friends"
condition="$friends=nonempty"
}%
%FORMELEMENT{
name="action"
type="submit"
buttonlabel="Submit"
}%
%ENDFORM%

%URLPARAM{"together" multiple="on"}%';
    
    my $response = $this->_submitForm( $input );
    my $result = $response->content;
    _removeValidationKey($result);
    
    my $expected = <<EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="x" id="x" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="x" />
<a name="FormElementfriends"><!--//--></a>
<p> <fieldset class="formPluginGroup formPluginGroupWithHint"><input id="friends_mary" name="friends" type="checkbox" value="mary" checked="1" class="foswikiCheckbox" /><label for="friends_mary">Mary M</label> <input id="friends_peter" name="friends" type="checkbox" value="peter" checked="1" class="foswikiCheckbox" /><label for="friends_peter">Peter P</label> <input id="friends_annabel" name="friends" type="checkbox" value="annabel" class="foswikiCheckbox" /><label for="friends_annabel">Annabel A</label> <input id="friends_nicky" name="friends" type="checkbox" value="nicky" class="foswikiCheckbox" /><label for="friends_nicky">Nicky N</label> <input id="friends_jennifer" name="friends" type="checkbox" value="jennifer" class="foswikiCheckbox" /><label for="friends_jennifer">Jennifer J</label></fieldset>  <span class="formPluginHint">Select any person</span> </p>
<input type="hidden" name="together" value="friends: \$friends" />
<input type="hidden" name="FP_condition_together" value="friends=s" />
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="3" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
<p />
friends: mary, peter
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod

Test condition param with not 'valid' input 

=cut

sub test_post_condition_invalid {
    my ($this) = @_;
    
    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
        
    my $input = '%STARTFORM{
name="x"
action="view"
}%
%FORMELEMENT{
name="friends"
type="checkbox"
options="mary, peter, annabel, nicky, jennifer"
labels="Mary M, Peter P, Annabel A, Nicky N, Jennifer J"
}%
%FORMELEMENT{
name="together"
type="hidden"
value="friends: $friends"
condition="$friends=nonempty"
}%
%FORMELEMENT{
name="action"
type="submit"
buttonlabel="Submit"
}%
%ENDFORM%

%URLPARAM{"together" multiple="on"}%';
    
    my $response = $this->_submitForm( $input );
    my $result = $response->content;
    _removeValidationKey($result);
    
    my $expected = <<EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl#FormPluginNotification" enctype="multipart/form-data" name="x" id="x" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl" />
<input type="hidden" name="FP_name" value="x" />
<a name="FormElementfriends"><!--//--></a>
<p> <fieldset class="formPluginGroup"><input id="friends_mary" name="friends" type="checkbox" value="mary" class="foswikiCheckbox" /><label for="friends_mary">Mary M</label> <input id="friends_peter" name="friends" type="checkbox" value="peter" class="foswikiCheckbox" /><label for="friends_peter">Peter P</label> <input id="friends_annabel" name="friends" type="checkbox" value="annabel" class="foswikiCheckbox" /><label for="friends_annabel">Annabel A</label> <input id="friends_nicky" name="friends" type="checkbox" value="nicky" class="foswikiCheckbox" /><label for="friends_nicky">Nicky N</label> <input id="friends_jennifer" name="friends" type="checkbox" value="jennifer" class="foswikiCheckbox" /><label for="friends_jennifer">Jennifer J</label></fieldset>   </p>
<input type="hidden" name="together" value="friends: \$friends" />
<input type="hidden" name="FP_condition_together" value="friends=s" />
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="3" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod

=cut

sub test_post_redirect_message_error {
    my ($this) = @_;
    
    my $actionUrl = 'http://cnn.com';

    my $viewUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );
    my $configureUrl =
      Foswiki::Func::getScriptUrl( undef, undef,
        'configure' );
    
    my $input = '%STARTFORM{
name="x"
action="' . $actionUrl . '"
}%
%FORMELEMENT{
name="action"
type="submit"
buttonlabel="Submit"
}%
%ENDFORM%';
    
    my $response = $this->_submitForm( $input );
    my $result = $response->content;
    _removeValidationKey($result);
    
    my $expected = <<EXPECTED;
<a name="FormPluginNotification"><!--//--></a><div class="formPluginError formPluginNotification"><span class="formPluginTitle">Could not redirect</span><span class="formPluginErrorItem"> Check if <code>AllowRedirectUrl</code> has been set in <a href="$configureUrl#Environment\$SecurityAndAuthentication" target="_top">configure</a> and if the url <a href="http://cnn.com" target="_top">http://cnn.com</a> is listed in configure's <a href="$configureUrl#GeneralPathSettings" target="_top">General path settings</a>.</span></div>
<!--FormPlugin form start--><form method="post" action="$viewUrl#FormPluginNotification" enctype="multipart/form-data" name="x" id="x" onsubmit="StrikeOne.submit(this)"><input type='hidden' name='validation_key' value='?' />
<div><input type="hidden" name="FP_actionurl" value="http://cnn.com" />
<input type="hidden" name="FP_name" value="x" />
<a name="FormElementaction"><!--//--></a>
<p> <input type="submit" tabindex="1" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div>
</form><!--/FormPlugin form end-->
EXPECTED

	_trimSpaces($expected);
	_trimSpaces($result);
	
	_debug("EXP:$expected");
	_debug("RES:$result");
	
    $this->assert_str_equals( $expected, $result, 0 );
}

=pod
sub __test_post_upload {
    my ($this) = @_;

    my $input  = '%STARTFORM{
name="uploadform"
action="upload"
topic="%WEB%.%TOPIC%"
method="post"
validate="off"
}%
%FORMELEMENT{
type="upload"
name="filepath"
title="Attach new file"
size="70"
}%
%FORMELEMENT{
name="filecomment"
type="text"
title="Comment"
}%
%FORMELEMENT{
name="hidefile"
type="checkbox"
options="on=Do not show attachment in table"
}%
%FORMELEMENT{
name="createlink"
type="checkbox"
options="on=Create a link to the attached file"
}%
%FORMELEMENT{
name="action"
type="submit"
buttonlabel="Upload file"
}%
%ENDFORM%';

    my $response = $this->_submitFormWithPictureUpload($input, 'filepath');

    #$this->assert_str_equals( "$testTopicUrl#$anchor", $location );
}
=cut


sub _debug {
    my ($text) = @_;

    return if !$DEBUG;
    Foswiki::Func::writeDebug($text);
    print STDOUT $text . "\n";
}

=pod

Copied from PrefsTests.
Used to set the SKIN preference to text, so that the smaller response page is easier to handle.

=cut

sub _setWebPref {
    my ( $this, $pref, $val, $type ) = @_;
    $this->_set( $this->{test_web}, $Foswiki::cfg{WebPrefsTopicName},
        $pref, $val, $type );
}

sub _set {
    my ( $this, $web, $topic, $pref, $val, $type ) = @_;
    $this->assert_not_null($web);
    $this->assert_not_null($topic);
    $this->assert_not_null($pref);
    $type ||= 'Set';

    my $user = $this->{session}->{user};
    $this->assert_not_null($user);
    my $topicObject = Foswiki::Meta->load( $this->{session}, $web, $topic );
    my $text = $topicObject->text();
    $text =~ s/^\s*\* $type $pref =.*$//gm;
    $text .= "\n\t* $type $pref = $val\n";
    $topicObject->text($text);
    try {
        $topicObject->save();
    }
    catch Foswiki::AccessControlException with {
        $this->assert( 0, shift->stringify() );
    }
    catch Error::Simple with {
        $this->assert( 0, shift->stringify() || '' );
    };
}

=pod

_trimSpaces( $text ) -> $text

Removes spaces from both sides of the text.

=cut

sub _trimSpaces {

    #my $text = $_[0]

    $_[0] =~ s/^[[:space:]]+//s;    # trim at start
    $_[0] =~ s/[[:space:]]+$//s;    # trim at end
}

sub _removeFoswikiRedirectCache {
    #my $text = $_[0]
	return if !defined $_[0];
	
	$_[0] =~ s/\?*foswiki_redirect_cache\=\w+//;
}

sub _removeValidationKey {
    #my $text = $_[0]
	return if !defined $_[0];
	
	$_[0] =~
s/name='validation_key' value='\?[[:alnum:]]+'/name='validation_key' value='?'/;
}

sub _saveTopicText {
    my ( $this, $formTML ) = @_;

	my $oopsUrl =
      Foswiki::Func::saveTopicText( $this->{test_web}, $this->{test_topic},
        $formTML );
    $this->assert_str_equals( '', $oopsUrl );
    my ( $meta, $text ) =
      Foswiki::Func::readTopic( $this->{test_web}, $this->{test_topic} );
    $this->assert_str_equals( $formTML, $text );

    return $text;
}

sub _renderHtml {
    my ( $web, $topic, $text ) = @_;

    my $rendered = Foswiki::Func::expandCommonVariables( $text, $topic, $web );
    $rendered = Foswiki::Func::renderText( $rendered, $web, $topic );
    return $rendered;
}

=pod

This formats the text up to immediately before <nop>s are removed, so we
can see the nops.

=cut

sub _performTestHtmlOutput {
    my ( $this, $expected, $actual, $doRender ) = @_;
    my $session   = $this->{session};
    my $webName   = $this->{test_web};
    my $topicName = $this->{test_topic};

    $actual = _renderHtml( $webName, $topicName, $actual ) if ($doRender);
    $this->assert_html_equals( $expected, $actual );
}

=pod

Get the HTTP::Response object from submitting a form.

=cut

sub _submitForm {
    my ( $this, $formTML ) = @_;

    my $form = $this->_form($formTML);

    use LWP::UserAgent;
    my $ua = LWP::UserAgent->new;

    my $response = $ua->request( $form->click );

#=pod
    _debug( "response=" . Dumper($response) );
    _debug( "is_success:" . $response->is_success );
    _debug( "status_line:" . $response->status_line );
    _debug( "content:" . $response->content );
    _debug( "location:" . $response->header('location') ) if defined $response->header('location');
#=cut

    return $response;
}

sub _form {
    my ( $this, $formTML ) = @_;

	my $text = $this->_saveTopicText($formTML);
    my $formHtml = _renderHtml( $this->{test_web}, $this->{test_topic}, $text );
    my $formUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'view' );

    return HTML::Form->parse( $formHtml, base => $formUrl, verbose => 1 );
}

=pod

Does not work yet - I am having troubles getting the user logged in so we don't get the login page in the response.

=cut

=pod
sub _submitFormWithPictureUpload {
    my ( $this, $formTML, $fieldName ) = @_;

	my $text = $this->_saveTopicText($formTML);
    my $formHtml = _renderHtml( $this->{test_web}, $this->{test_topic}, $text );
    my $formUrl =
      Foswiki::Func::getScriptUrl( $this->{test_web}, $this->{test_topic},
        'viewauth' );

	my $pictureData = Foswiki::Func::readAttachment( 'System', 'FormPlugin', 'screenshot_validation_example.png' );

    my $form = HTML::Form->parse( $formHtml, base => $formUrl, verbose => 1 );

	$this->{session}->finish();
	my $query = new Unit::Request(
        {
            username => [ $Foswiki::cfg{AdminUserLogin} ],
            password => [$password],
            Logon    => [1],
        }
    );
    $query->path_info("/$this->{test_web}/$this->{test_topic}");
	$this->{session} = new Foswiki( undef, $query );
    $this->{session}->getLoginManager()->login( $query, $this->{session} );
    my $script = $Foswiki::cfg{LoginManager} =~ /Apache/ ? 'viewauth' : 'view';
    my $surly =
      $this->{session}
      ->getScriptUrl( 0, $script, $this->{test_web}, $this->{test_topic} );
    $this->assert_matches( qr/^307/, $this->{session}->{response}->status() );        
    $this->assert_matches( qr/^$surly/,
        $this->{session}->{response}->headers()->{Location} );
	
    
    use LWP::UserAgent;
    my $ua = LWP::UserAgent->new;
	$ua->credentials($formUrl, "Foswiki", $Foswiki::cfg{AdminUserLogin}, $password);

    my $response = $ua->request( $form->click, [ $fieldName => ["$pictureData"]]);

    _debug( "response=" . Dumper($response) );
    _debug( "is_success:" . $response->is_success );
    _debug( "status_line:" . $response->status_line );
    _debug( "content:" . $response->content );
    _debug( "location:" . $response->header('location') );
    
    my ( $m, $t ) = Foswiki::Func::readTopic( $this->{test_web}, $this->{test_topic} );
my @attachments = $m->find( 'FILEATTACHMENT' );
foreach my $a ( @attachments ) {
   try {
   	_debug("trying to open $a->{name}");
       my $d = Foswiki::Func::readAttachment( $this->{test_web}, $this->{test_topic}, $a->{name} );
       _debug( Dumper($d) );
   } catch Foswiki::AccessControlException with {
   };
}

    return $response;
}
=cut

1;
