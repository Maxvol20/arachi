require 'nokogiri'
require 'json'
require 'sinatra'
require 'sinatra/contrib'
require 'open-uri'
require_relative '../check_server'

def get_variations( str )
    return if str.to_s.empty?

    str = str.split( "\0" ).first
    return if !str

    str = "http://#{str}" if !(str.start_with?( 'http://' ) || str.start_with?( 'https://' ))
    redirect( str.split( "\0" ).first.to_s.upcase ) rescue nil
end

def get_js_variations( str )
    "<script>window.location.replace(#{str.inspect})</script>"
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
        <a href="/json">JSON</a>
        <a href="/xml">XML</a>
    EOHTML
end

get "/link" do
    <<-EOHTML
        <a href="/link/straight?input=default">Link</a>
        <a href="/link/append?input=default">Link</a>
        <a href="/link/prepend?input=default">Link</a>
        <a href="/link/js?input=default">Link</a>
    EOHTML
end

get '/link/straight' do
    default = 'default'
    return if params['input'].start_with?( default )

    get_variations( params['input'].split( default ).last )
end

get '/link/append' do
    default = 'default'
    return if !params['input'].start_with?( default )

    get_variations( params['input'].split( default ).last )
end

get '/link/prepend' do
    default = 'default'
    return if !params['input'].end_with?( default )

    get_variations( params['input'].split( default ).last )
end


get '/link/js' do
    get_js_variations( params['input'] )
end

get '/form' do
    <<-EOHTML
        <form action="/form/straight">
            <input name='input' value='default' />
        </form>

        <form action="/form/append">
            <input name='input' value='default' />
        </form>

        <form action="/form/prepend">
            <input name='input' value='default' />
        </form>

        <form action="/form/js">
            <input name='input' value='default' />
        </form>
    EOHTML
end

get '/form/straight' do
    default = 'default'
    return if !params['input'] || params['input'].start_with?( default )

    get_variations( params['input'].split( default ).last )
end

get '/form/append' do
    default = 'default'
    return if !params['input'] || !params['input'].start_with?( default )

    get_variations( params['input'].split( default ).last )
end

get '/form/prepend' do
    default = 'default'
    return if !params['input'] || !params['input'].end_with?( default )

    get_variations( params['input'].split( default ).last )
end

get '/form/js' do
    get_js_variations( params['input'] )
end

get '/cookie' do
    <<-EOHTML
        <a href="/cookie/straight">Cookie</a>
        <a href="/cookie/append">Cookie</a>
        <a href="/cookie/prepend">Cookie</a>
        <a href="/cookie/js">Cookie</a>
    EOHTML
end

get '/cookie/straight' do
    default = 'cookie value'
    cookies['cookie'] ||= default

    return if cookies['cookie'].start_with?( default )

    get_variations( cookies['cookie'].split( default ).last )
end

get '/cookie/append' do
    default = 'cookie value'
    cookies['cookie2'] ||= default
    return if !cookies['cookie2'].start_with?( default )

    get_variations( cookies['cookie2'].split( default ).last )
end

get '/cookie/prepend' do
    default = 'cookie value'
    cookies['cookie2'] ||= default
    return if !cookies['cookie2'].end_with?( default )

    get_variations( cookies['cookie2'].split( default ).last )
end

get '/cookie/js' do
    get_js_variations( cookies['cookie2'] )
end

get '/nested_cookie' do
    <<-EOHTML
        <a href="/nested_cookie/straight">Nested cookie</a>
        <a href="/nested_cookie/append">Nested cookie</a>
        <a href="/nested_cookie/js">Nested cookie</a>
    EOHTML
end

get '/nested_cookie/straight' do
    default = 'nested cookie value'
    cookies['nested_cookie'] ||= "name=#{default}"

    value = Arachni::NestedCookie.parse_inputs( cookies['nested_cookie'] )['name'].to_s
    return if value.start_with?( default )

    get_variations( value )
end

get '/nested_cookie/prepend' do
    default = 'nested cookie value'
    cookies['nested_cookie'] ||= "name=#{default}"

    value = Arachni::NestedCookie.parse_inputs( cookies['nested_cookie'] )['name'].to_s
    return if !value.end_with?( default )

    get_variations( value.split( default ).last )
end

get '/nested_cookie/js' do
    default = 'nested cookie value'
    cookies['nested_cookie'] ||= "name=#{default}"

    value = Arachni::NestedCookie.parse_inputs( cookies['nested_cookie'] )['name'].to_s
    get_js_variations( value )
end

get '/header' do
    <<-EOHTML
        <a href="/header/straight">Header</a>
        <a href="/header/append">Header</a>
        <a href="/header/prepend">Header</a>
        <a href="/header/js">Header</a>
    EOHTML
end

get '/header/straight' do
    default = 'arachni_user'
    return if !env['HTTP_USER_AGENT'] || env['HTTP_USER_AGENT'].start_with?( default )

    get_variations( env['HTTP_USER_AGENT'].split( default ).last )
end

get '/header/append' do
    default = 'arachni_user'
    return if !env['HTTP_USER_AGENT'] || !env['HTTP_USER_AGENT'].start_with?( default )

    get_variations( env['HTTP_USER_AGENT'].split( default ).last )
end

get '/header/prepend' do
    default = 'arachni_user'
    return if !env['HTTP_USER_AGENT'] || !env['HTTP_USER_AGENT'].end_with?( default )

    get_variations( env['HTTP_USER_AGENT'].split( default ).last )
end

get '/header/js' do
    get_js_variations( env['HTTP_USER_AGENT'] )
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

            http_request = new XMLHttpRequest();
            http_request.open( "POST", "/json/prepend", true);
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

post "/json/prepend" do
    return if !@json

    default = 'arachni_user'
    return if !@json['input'].end_with?( default )

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
                http_request.open( "POST", "/xml/text/prepend", true);
                http_request.send( '<input>arachni_user</input>' );

                http_request = new XMLHttpRequest();
                http_request.open( "POST", "/xml/attribute/straight", true);
                http_request.send( '<input my-attribute="arachni_user">stuff</input>' );

                http_request = new XMLHttpRequest();
                http_request.open( "POST", "/xml/attribute/append", true);
                http_request.send( '<input my-attribute="arachni_user">stuff</input>' );

                http_request = new XMLHttpRequest();
                http_request.open( "POST", "/xml/attribute/prepend", true);
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

post "/xml/text/prepend" do
    return if !@xml

    default = 'arachni_user'
    input = @xml.css('input').first.content

    return if !input.end_with?( default )

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

post "/xml/attribute/prepend" do
    return if !@xml

    default = 'arachni_user'
    input = @xml.css('input').first['my-attribute']

    return if !input.end_with?( default )

    get_variations( input.split( default ).last )
end
