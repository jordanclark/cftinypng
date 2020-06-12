component {

	function init(
		required string apiKey
	,	string apiUrl="https://api.tinify.com"
	,	string s3AccessKeyId=""
	,	string s3SecretAccessKey=""
	,	string s3Region="us-west-1"
	,	numeric httpTimeOut= 120
	,	boolean debug
	) {
		arguments.debug = ( arguments.debug ?: request.debug ?: false );
		this.apiKey = arguments.apiKey;
		this.apiUrl = arguments.apiUrl;
		this.s3AccessKeyId = arguments.s3AccessKeyId;
		this.s3SecretAccessKey = arguments.s3SecretAccessKey;
		this.s3Region = arguments.s3Region;
		this.httpTimeOut = arguments.httpTimeOut;
		this.debug = arguments.debug;
		return this;
	}

	function debugLog(required input) {
		if ( isCustomFunction( request.log ?: 0 ) ) {
			if ( isSimpleValue( arguments.input ) ) {
				request.log( "tinypng: " & arguments.input );
			} else {
				request.log( "tinypng: (complex type)" );
				request.log( arguments.input );
			}
		} else if( this.debug ) {
			var info= ( isSimpleValue( arguments.input ) ? arguments.input : serializeJson( arguments.input ) );
			cftrace(
				var= "info"
			,	category= "tinypng"
			,	type= "information"
			);
		}
		return;
	}

	struct function shrinkURL(required string url) {
		var out= this.apiRequest(
			path= "/shrink"
		,	verb= "POST"
		,	json= '{"source":{"url":"#arguments.url#"}}'
		);
		return out;
	}

	struct function shrinkImage(required image) {
		var f = 0;
		if ( isBinary( arguments.image ) ) {
			f = arguments.image;
		} else if ( isSimpleValue( arguments.image ) ) {
			cfimage( source=arguments.image, name="f" );
			f = imageGetBlob( f );
		}
		var out= this.apiRequest( 
			path= "/shrink"
		,	verb= "POST"
		,	sendFile= f
		);
		return out;
	}

	/**
	 * getImage
	 *
	 * @urlOrKey full url or last part of url
	 * @file local filename to save as
	 * @resize resize operations: scale-width:100 or scale-height:200 or fit:100x200 or cover:100x200 or thumb:100x200
	 */
	struct function getImage(required string urlOrKey, required string file, string resize="") {
		var json = '{}';
		if ( listFirst( arguments.resize, ":," ) == "scale-width" && listLen( arguments.resize, ":," ) == 2 ) {
			json = '{"resize":{"method": "scale","width":#listGetAt( arguments.resize, 2, ':,' )#}}';
		} else if ( listFirst( arguments.resize, ":," ) == "scale-height" && listLen( arguments.resize, ":," ) == 2 ) {
			json = '{"resize":{"method": "scale","height":#listGetAt( arguments.resize, 2, ':,' )#}}';
		} else if ( listLen( arguments.resize, ";,x" ) == 3 ) {
			json = '{"resize":{"method": "#listGetAt( arguments.resize, 1, ':,x' )#","width":#listGetAt( arguments.resize, 2, ':,x' )#,"height":#listGetAt( arguments.resize, 3, ':,x' )#}}';
		}
		var out= this.apiRequest( 
			path= "/output/#listLast( arguments.urlOrKey, '/' )#"
		,	verb= "POST"
		,	saveFile= arguments.file
		,	json= json
		);
		return out;
	}

	struct function s3transfer(
		required string key
	,	required string path
	,	required string accessKeyId=this.s3AccessKeyId
	,	required string secretAccessKey=this.s3SecretAccessKey
	,	string region=this.s3Region
	) {
		var json = '{"store":{"service":"s3","aws_access_key_id":"#arguments.accessKeyId#","aws_secret_access_key":"#arguments.secretAccessKey#","region":"#arguments.region#","path":"#arguments.path#"}}';
		var out= this.apiRequest( 
			path= "/output/#listLast( arguments.key, '/' )#"
		,	verb= "POST"
		,	json= json
		);
		return out;
	}

	struct function apiRequest(required string path, string verb="POST", json="", sendFile, string saveFile="") {
		var http = {};
		var dataKeys = 0;
		var item = "";
		var out = {
			success = false
		,	error = ""
		,	status = ""
		,	json = ""
		,	statusCode = 0
		,	response = ""
		,	verb = arguments.verb
		,	requestUrl = this.apiUrl & arguments.path
		};
		if ( isStruct( arguments.json ) ) {
			out.json = serializeJSON( arguments.json, false, false );
			out.json = reReplace( out.json, "[#chr(1)#-#chr(7)#|#chr(11)#|#chr(14)#-#chr(31)#]", "", "all" );
		} else if ( isSimpleValue( arguments.json ) && len( arguments.json ) ) {
			out.json = arguments.json;
		}
		this.debugLog( out.verb & ": " & arguments.path );
		if ( len( out.json ) ) {
			this.debugLog( out.json );
		}
		this.debugLog( out );

		cftimer( type="debug", label="tinypng request #out.requestUrl#" ) {
			cfhttp( result="http", method=out.verb, url=out.requestUrl, getAsBinary=( len( arguments.saveFile ) ? 'yes' : 'no' ), charset="UTF-8", throwOnError=false, timeOut=this.httpTimeOut ) {
				cfhttpparam( name="Authorization", type="header", value="Basic #ToBase64('api:#this.apiKey#')#" );
				if ( len( out.json ) ) {
					cfhttpparam( name="Content-Type", type="header", value="application/json" );
					cfhttpparam( type="body", value=out.json );
				}
				if ( structKeyExists( arguments, "sendFile" ) ) {
					cfhttpparam( name="Content-Type", type="header", value="image/*" );
					cfhttpparam( type="body", value=arguments.sendFile );
				}
			}
			if( this.debug ) {
				out.http= http;
			}
		}
		
		if ( len( arguments.saveFile ) ) {
			out.response = arguments.saveFile;
			if ( !structKeyExists( server, "railo" ) || structKeyExists( server, "lucee" ) ) {
				fileWrite( arguments.saveFile, http.fileContent );
			} else {
				fileWrite( arguments.saveFile, http.fileContent.toByteArray() );
			}
			out.width = http.responseHeader[ "Image-Width" ] ?: 0;
			out.height = http.responseHeader[ "Image-Height" ] ?: 0;
		} else {
			out.response = toString( http.fileContent );
			// this.debugLog( out.response );
		}
		out.statusCode = http.responseHeader.Status_Code ?: 500;
		if ( left( out.statusCode, 1 ) == 4 || left( out.statusCode, 1 ) == 5 ) {
			out.error = "status code error: #out.statusCode#";
		} else if ( out.response == "Connection Timeout" || out.response == "Connection Failure" ) {
			out.error = out.response;
		} else if ( left( out.statusCode, 1 ) == 2 ) {
			out.success = true;
			out.image = http.responseHeader[ "Location" ] ?: "";
			out.type = http.responseHeader[ "Content-Type" ] ?: "";
			out.compressionCount= http.responseHeader[ "Compression-Count" ] ?: -1;
		}
		// parse response 
		if ( len( out.response ) && left( out.response, 1 ) == "{" ) {
			try {
				out.response = deserializeJSON( out.response );
				out.width = out.response.output.width ?: 0;
				out.height = out.response.output.height ?: 0;
				out.image = out.response.output.url ?: "";
				out.type = out.response.output.type ?: "";
			} catch (any cfcatch) {
				out.error= "JSON Error: " & (cfcatch.message?:"No catch message") & " " & (cfcatch.detail?:"No catch detail");
			}
		}
		if ( len( out.error ) ) {
			out.success = false;
		}
		this.debugLog( out.statusCode & " " & out.error );
		return out;
	}

}
