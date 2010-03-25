use strict;

# tests for basic formatting

package FormPluginTests;

use FoswikiFnTestCase;
our @ISA = qw( FoswikiFnTestCase );

use strict;

#use Foswiki::UI::Save;
use Error qw( :try );

#use Foswiki::Plugins::FormPlugin;
use Data::Dumper;    # for debugging
use HTML::Form;
use HTTP::Request;
use LWP::UserAgent;

my $query;
my $DEBUG = 0;

sub new {
    my $self = shift()->SUPER::new( 'FormPluginFunctions', @_ );
    return $self;
}

sub set_up {
    my $this = shift;

    $this->SUPER::set_up();

    $this->{session}->enterContext('FormPluginEnabled');
    $Foswiki::cfg{AllowRedirectUrl} = 1;    # to test redirectto param

    # to make the received topic text less cluttered
    $this->_setWebPref( "SKIN", "text" );
}

#sub tear_down {
#    my $this = shift;
#}

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
    my ( $this, $formTML, $topic ) = @_;

    my $testTopic = $topic || 'FormTestTopic';
    my $testWeb = $this->{test_web};

    my $oopsUrl =
      Foswiki::Func::saveTopicText( $testWeb, $testTopic, $formTML );
    $this->assert_str_equals( '', $oopsUrl );
    my ( $meta, $text ) = Foswiki::Func::readTopic( $testWeb, $testTopic );
    $this->assert_str_equals( $formTML, $text );

    my $formHtml = _renderHtml( $testWeb, $testTopic, $text );
    my $formUrl = Foswiki::Func::getScriptUrl( $testWeb, $testTopic, 'view' );

    my $form = HTML::Form->parse( $formHtml, $formUrl );
    _debug( "form=" . Dumper($form) );

    my $ua = LWP::UserAgent->new;

    _debug( "ua=" . Dumper($ua) );

    my HTTP::Request $clicked = $form->click;
    _debug( "clicked=" . Dumper($clicked) );
    my $response = $ua->request($clicked);
    $this->assert( $response->is_success );

    _debug( "_submitForm; response=" . Dumper($response) );
    _debug( "content=" . $response->content );
    return $response;
}

=pod

=cut

sub test_simple_form {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = 'BEFORE
%STARTFORM{
name="myform"
action="view"
}%
%ENDFORM%
AFTER';
    my $expected = <<END_EXPECTED;
BEFORE
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
AFTER
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_form_no_name_no_action {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<span class="foswikiAlert"><nop>FormPlugin warning: Parameters =name= and =action= are required for =STARTFORM=.</span>
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_form_no_name {
    my ($this) = @_;

    my $topic = 'WebHome';
    my $web   = 'Main';

    my $input = '%STARTFORM{
action="view"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<span class="foswikiAlert"><nop>FormPlugin warning: Parameter =name= is required for =STARTFORM= (missing at form with action: =view=).</span>
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_form_no_action {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<span class="foswikiAlert"><nop>FormPlugin warning: Parameter =action= is required for =STARTFORM= (missing at form with name: myform).</span>
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_action_custom {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'attach' );

    my $input = '%STARTFORM{
name="myform"
action="%SCRIPTURL{attach}%/' . $web . '/' . $topic . '"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    $input = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_id {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
id="glow in the dark"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="glow in the dark">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_topic {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = $this->{test_web};
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
topic="WebHome"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_web {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( 'MyWeb', $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
web="MyWeb"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_anchor {
    my ($this) = @_;

    my $topic = 'WebHome';
    my $web   = 'Main';
    my $scriptUrl =
      Foswiki::Func::getScriptUrl( $web, $topic, 'view' ) . "#StartHere";

    my $input = '%STARTFORM{
name="myform"
action="view"
anchor="StartHere"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub __test_post_startform_param_anchor {
    my ($this) = @_;

    my $topic = $this->{test_topic};
    my $web   = $this->{test_web};

    my $anchor = 'StartHere';
    my $input  = '%STARTFORM{
name="myform"
action="view"
anchor="StartHere"
}%
%ENDFORM%';

    my $testTopicUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );
    my $response = $this->_submitForm( $input, $topic );

    $this->assert_str_equals( "$testTopicUrl#$anchor",
        $response->request->uri );
}

=pod

=cut

sub test_startform_param_method_post {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
method="POST"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_method_get {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
method="GET"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="get" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_method_empty {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
method=""
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_redirectto {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
redirectto="System.SitePreferences"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
<input type="hidden" name="redirectto" value="System.SitePreferences"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

TEST DOES NOT WORK

=cut

sub __test_post_startform_param_redirectto {
    my ($this) = @_;

    my $topic = 'WebHome';
    my $web   = 'Main';

    my $input = '%STARTFORM{
name="myform"
action="save"
redirectto="System.SitePreferences"
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

 # we cannot test the actual redirected to topic, but we should see a 302 statys
    $this->assert_equals( '302', $response->code );
}

=pod

=cut

sub test_startform_param_formcssclass {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
formcssclass="foswikiFormSteps"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div class="foswikiFormSteps">
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_elementcssclass {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

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
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div class="foswikiFormSteps">
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
<a name="FormElementName"><!--//--></a>
<div class="foswikiFormStep"><p> <span class="formPluginTitle">Enter your name:</span> <br /> <noautolink><input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p></div>
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_noformhtml {
    my ($this) = @_;

    my $topic = 'WebHome';
    my $web   = 'Main';

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

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_onSubmit {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
onSubmit="return notify(this)"
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" onsubmit="return notify(this)" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_sep_nospace {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
sep=""
}%
%ENDFORM%';
    my $expected = <<END_EXPECTED;
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div>
<input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_sep_with_table {
    my ($this) = @_;

    my $topic     = 'WebHome';
    my $web       = 'Main';
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

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
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform"><div><input type="hidden" name="FP_actionurl" value="$scriptUrl"  /><input type="hidden" name="FP_submit" value="myform"  />
| <a name="FormElementName"><!--//--></a><p> <span class="formPluginTitle">Enter your name:</span> <br /> <noautolink><input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" /></noautolink>   </p> |
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub test_startform_param_validate {
    my ($this) = @_;

    my $topic     = $this->{test_topic};
    my $web       = $this->{test_web};
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );

    my $input = '%STARTFORM{
name="myform"
action="view"
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
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform">
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
<a name="FormElementName"><!--//--></a>
<p> <noautolink><input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" /></noautolink> <span class="formPluginMandatory">*</span>  </p>
<input type="hidden" name="FP_validate_Name" value="Name=s"  />
<a name="FormElementaction"><!--//--></a>
<p> <noautolink><input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" /></noautolink>   </p>
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    my $result = Foswiki::Func::expandCommonVariables( $input, $topic, $web );
    $this->_performTestHtmlOutput( $expected, $result, 0 );
}

=pod

=cut

sub __test_post_formelement_param_validate_mandatory_field_empty {
    my ($this) = @_;

    my $topic     = $this->{test_topic};
    my $web       = $this->{test_web};
    my $scriptUrl = Foswiki::Func::getScriptUrl( $web, $topic, 'view' );
    my $pubUrlSystemWeb =
        Foswiki::Func::getUrlHost()
      . Foswiki::Func::getPubUrlPath() . '/'
      . $Foswiki::cfg{SystemWebName};

    my $input = '%STARTFORM{
name="myform"
action="view"
}%
%FORMELEMENT{
name="Name"
type="text"
value=""
mandatory="on"
}%
%FORMELEMENT{
name="action"
type="submit"
value="Submit"
}%
%ENDFORM%';

    # remove validation key
    my $STRIKEONE_SUBSTITUTE = '';
    my $expected             = <<END_EXPECTED;
<a name="FormPluginNotification"><!--//--></a><div class="formPluginError formPluginNotification"><img src="$pubUrlSystemWeb/FormPlugin/error.gif" alt="" width="16" height="16" /> <strong>Some fields are not filled in correctly:</strong> <span class="formPluginErrorItem"><a href="$scriptUrl#FormElementName">Name</a> - please enter a value</span></div>
<!--FormPlugin form start--><form method="post" action="$scriptUrl" enctype="multipart/form-data" name="myform" id="myform" onsubmit="foswikiStrikeOne(this)"><input type='hidden' name='validation_key' value='?$STRIKEONE_SUBSTITUTE' />
<div><input type="hidden" name="FP_actionurl" value="$scriptUrl"  />
<input type="hidden" name="FP_submit" value="myform"  />
<a name="FormElementName"></a>
<p> <input type="text" name="Name" tabindex="1"  size="40" class="foswikiInputField" /> <span class="formPluginMandatory">*</span>  </p>
<input type="hidden" name="FP_validate_Name" value="Name=s"  />
<a name="FormElementaction"></a>
<p> <input type="submit" tabindex="2" name="action" value="Submit" class="foswikiSubmit" />   </p>
</div></form><!--/FormPlugin form end-->
END_EXPECTED

    _trimSpaces($expected);

    my $response = $this->_submitForm( $input, $topic );
    my $result = $response->content;

    # remove validation key
    $result =~
s/name='validation_key' value='\?[[:alnum:]]+'/name='validation_key' value='?$STRIKEONE_SUBSTITUTE'/;

    #_debug("expected=$expected");
    #_debug("result=$result");
    $this->assert_str_equals( $expected, $result );
}

sub _debug {
    my ($text) = @_;

	return if !$DEBUG;
    Foswiki::Func::writeDebug($text);
    print STDOUT $text . "\n";
}

=pod

TODO:

STARTFORM:
validate
redirectto
showerrors
noredirect

=cut

1;
