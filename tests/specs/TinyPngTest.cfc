component extends="testbox.system.BaseSpec" {

	// executes before all suites
	function beforeAll() {
		// ensure struct exists to support acf2016
		if( !structKeyExists( server, "system" ) ) {
			server.system= {
				environment= createObject( "java", "java.lang.System" ).getenv()
			,	properties= createObject( "java", "java.lang.System" ).getProperties()
			};
		}
		request.log= function( input ) {
			debug( arguments.input );
		};
	}

    // executes after all suites
    function afterAll() {
		structDelete( request, "log" );
	}

 	// All suites go in here
	function run( testResults, testBox ){
		describe("Basic tinypng operations", function(){
			beforeEach(function( currentSpec ) {
				TINYPNG_API = server.system.environment.TINYPNG_API ?: "missing-api-key";
				expect( TINYPNG_API ?: "" ).notToBe( "missing-api-key" );
				cfc = new tinypng( apiKey= TINYPNG_API, debug= true );
			});
			afterEach( function( currentSpec ) {
				structDelete( variables, "cfc" );
			});

			it("can shrink images by filename", function(){
				var result= cfc.shrinkImage( getDirectoryFromPath( getCurrentTemplatePath() ) & "caricature.png" );
				expect( result.success ).toBeTrue();
				expect( result.response.input.type ?: "" ).toBe( "image/png" );
				expect( result.response.output.type ?: "" ).toBe( "image/png" );
				expect( result.response.output.size ?: 0 ).toBeLTE( "18000", "compressed file size" );
				expect( result.image ?: "" ).toMatch( "^https://api.tinify.com/output/" );
				expect( result.width ?: 0 ).toBe( 212 );
				expect( result.height ?: 0 ).toBe( 400 );
				expect( result.compressionCount ?: 0 ).toBeGTE( 1, "compression count" );
			});
			it("can shrink binary images", function(){
				var result= cfc.shrinkImage( fileReadBinary( getDirectoryFromPath( getCurrentTemplatePath() ) & "caricature.png" ) );
				expect( result.success ).toBeTrue();
				expect( result.response.input.type ?: "" ).toBe( "image/png" );
				expect( result.response.output.type ?: "" ).toBe( "image/png" );
				expect( result.response.output.size ?: 0 ).toBeLTE( "18000", "compressed file size" );
				expect( result.image ?: "" ).toMatch( "^https://api.tinify.com/output/" );
				expect( result.width ?: 0 ).toBe( 212 );
				expect( result.height ?: 0 ).toBe( 400 );
				expect( result.compressionCount ?: 0 ).toBeGTE( 1, "compression count" );
			});
			it("can shrink images by URL", function(){
				var result= cfc.shrinkUrl( "https://www.imagineer.ca/images/caricature.png" );
				expect( result.success ).toBeTrue();
				expect( result.response.input.type ?: "" ).toBe( "image/png" );
				expect( result.response.output.type ?: "" ).toBe( "image/png" );
				expect( result.image ?: "" ).toMatch( "^https://api.tinify.com/output/" );
				expect( result.width ?: 0 ).toBe( 212 );
				expect( result.height ?: 0 ).toBe( 400 );
				expect( result.compressionCount ?: 0 ).toBeGTE( 1, "compression count" );
			});
			it("can download compressed images", function(){
				var result= cfc.shrinkUrl( "https://www.imagineer.ca/images/caricature.png" );
				expect( result.success ).toBeTrue();
				var download= cfc.getImage( result.image, "./download.png" );
				expect( download.success ).toBeTrue();
				expect( download.width ?: 0 ).toBe( 212 );
				expect( download.height ?: 0 ).toBe( 400 );
				debug( download );
			});
		});
   
   }

}