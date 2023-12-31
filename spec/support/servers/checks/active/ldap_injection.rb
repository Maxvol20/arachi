require 'nokogiri'
require 'json'
require 'sinatra'
require 'sinatra/contrib'
require_relative '../check_server'

def get_variations( str )
    root = File.dirname( __FILE__ ) + '/../../../../../'
    IO.read( root + 'components/checks/active/ldap_injection/errors.txt' ) if str == "#^($!@$)(()))******"
end

before do
    request.body.rewind
    begin
        @json = JSON.parse( request.body.read )
    rescue JSON::ParserError
    end
    request.body.rewind

    begin
        @xml = Nokogiri::XML( request.body.read )
    rescue JSON::ParserError
    end
    request.body.rewind
end

get '/' do
    <<-EOHTML
        <a href="/link?input=default">Link</a>
        <a href="/form">Form</a>
        <a href="/cookie">Cookie</a>
        <a href="/nested_cookie">Nested cookie</a>
        <a href="/header">Header</a>
        <a href="/link-template">Link template</a>
        <a href="/json">JSON</a>
        <a href="/xml">XML</a>
    EOHTML
end

get '/link' do
    <<-EOHTML
        <a href="/link/append?input=default">Link</a>
    EOHTML
end

get '/link/append' do
    default = 'default'
    return if !params['input'].start_with?( default )

    get_variations( params['input'].split( default ).last )
end

get '/link-template' do
    <<-EOHTML
        <a href="/link-template/append/input/default/stuff">Link</a>
    EOHTML
end

get '/link-template/append/input/*/stuff' do
    val = params[:splat].first
    default = 'default'
    return if !val.start_with?( default )

    get_variations( val.split( default ).last )
end

get '/form' do
    <<-EOHTML
        <form action="/form/append">
            <input name='input' value='default' />
        </form>
    EOHTML
end

get '/form/append' do
    default = 'default'
    return if !params['input'] || !params['input'].start_with?( default )

    get_variations( params['input'].split( default ).last )
end


get '/cookie' do
    <<-EOHTML
        <a href="/cookie/append">Cookie</a>
    EOHTML
end

get '/cookie/append' do
    default = 'cookie value'
    cookies['cookie2'] ||= default
    return if !cookies['cookie2'].start_with?( default )

    get_variations( cookies['cookie2'].split( default ).last )
end

get '/nested_cookie' do
    <<-EOHTML
            <a href="/nested_cookie/append">Nested cookie</a>
    EOHTML
end

get '/nested_cookie/append' do
    default = 'nested cookie value'
    cookies['nested_cookie'] ||= "name=#{default}"

    value = Arachni::NestedCookie.parse_inputs( cookies['nested_cookie'] )['name'].to_s
    return if !value.start_with?( default )

    get_variations( value.split( default ).last )
end

get '/header' do
    <<-EOHTML
        <a href="/header/append">Cookie</a>
    EOHTML
end

get '/header/append' do
    default = 'arachni_user'
    return if !env['HTTP_USER_AGENT'].start_with?( default )

    get_variations( env['HTTP_USER_AGENT'].split( default ).last )
end

get "/json" do
    <<-EOHTML
        <script type="application/javascript">
            http_request = new XMLHttpRequest();
            http_request.open( "POST", "/json/straight", true);
            http_request.send( '{"input": "arachni_user"}' );

            http_request = new XMLHttpRequest();
            http_request.open( "POST", "/json/append", true);
            http_request.send( '{"input": "arachni_user"}' );
        </script>
    EOHTML
end

post "/json/straight" do
    return if !@json
    default = 'arachni_user'
    return if @json['input'].start_with?( default )

    get_variations( @json['input'] )
end

post "/json/append" do
    return if !@json
    default = 'arachni_user'
    return if !@json['input'].start_with?( default )

    get_variations( @json['input'].split( default ).last )
end

get "/xml" do
    <<-EOHTML
            <script type="application/javascript">
                http_request = new XMLHttpRequest();
                http_request.open( "POST", "/xml/text/straight", true);
                http_request.send( '<input>arachni_user</input>' );

                http_request = new XMLHttpRequest();
                http_request.open( "POST", "/xml/text/append", true);
                http_request.send( '<input>arachni_user</input>' );

                http_request = new XMLHttpRequest();
                http_request.open( "POST", "/xml/attribute/straight", true);
                http_request.send( '<input my-attribute="arachni_user">stuff</input>' );

                http_request = new XMLHttpRequest();
                http_request.open( "POST", "/xml/attribute/append", true);
                http_request.send( '<input my-attribute="arachni_user">stuff</input>' );
            </script>
    EOHTML
end

post "/xml/text/straight" do
    return if !@xml

    default = 'arachni_user'
    input = @xml.css('input').first.content

    return if input.start_with?( default )

    get_variations( input )
end

post "/xml/text/append" do
    return if !@xml

    default = 'arachni_user'
    input = @xml.css('input').first.content

    return if !input.start_with?( default )

    get_variations( input.split( default ).last )
end

post "/xml/attribute/straight" do
    return if !@xml

    default = 'arachni_user'
    input = @xml.css('input').first['my-attribute']

    return if input.start_with?( default )

    get_variations( input )
end

post "/xml/attribute/append" do
    return if !@xml

    default = 'arachni_user'
    input = @xml.css('input').first['my-attribute']

    return if !input.start_with?( default )

    get_variations( input.split( default ).last )
end
