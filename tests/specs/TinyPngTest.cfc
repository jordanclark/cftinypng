component extends="coldbox.system.testing.BaseTestCase" {

	// executes before all suites
	function beforeAll() {
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
				cfc = new tinypng( apiKey= "jgnrP2JvrVHSpJ1qfriO_vE4PHDkJA8F", debug= true );
			});
			afterEach( function( currentSpec ) {
				structDelete( variables, "cfc" );
			});
			debug( cgi );
			debug( getUtil() );
			debug( server.system.environment );
			
			// it("can shrink images by URL", function(){
			// 	var result= cfc.shrinkUrl( "https://www.imagineer.ca/images/caricature.png" );
			// 	expect( result.success ).toBeTrue();
			// 	expect( result.response.input.type ?: "" ).toBe( "image/png" );
			// 	expect( result.response.output.type ?: "" ).toBe( "image/png" );
			// 	debug( result );
			// });
			// it("can shrink images by filename", function(){
			// 	var result= cfc.shrinkImage( getDirectoryFromPath( getCurrentTemplatePath() ) & "caricature.png" );
			// 	expect( result.success ).toBeTrue();
			// 	expect( result.response.input.type ?: "" ).toBe( "image/png" );
			// 	expect( result.response.input.size ?: 0 ).toBe( "26060", "original file size" );
			// 	expect( result.response.output.type ?: "" ).toBe( "image/png" );
			// 	expect( result.response.output.size ?: 0 ).toBeLTE( "18000", "compressed file size" );
			// 	debug( result );
			// });
			// it("can shrink binary images", function(){
			// 	var result= cfc.shrinkImage( fileReadBinary( getDirectoryFromPath( getCurrentTemplatePath() ) & "caricature.png" ) );
			// 	expect( result.success ).toBeTrue();
			// 	expect( result.response.input.type ?: "" ).toBe( "image/png" );
			// 	expect( result.response.input.size ?: 0 ).toBe( "19603", "original file size" );
			// 	expect( result.response.output.type ?: "" ).toBe( "image/png" );
			// 	expect( result.response.output.size ?: 0 ).toBeLTE( "18000", "compressed file size" );
			// 	debug( result );
			// });
		});
   
   }

}