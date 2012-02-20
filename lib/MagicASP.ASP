<!-- #include file="MagicASP_Utility.ASP" -->
<script Language="JScript" RunAt="Server">
/*
 * MagicASP һ��ASP�ļ��Զ��ϲ����� ����ͳһURL. 
 * @version: beta
 * @author:qpwoeiru96
 * @link: http://sou.la/blog
 * @date: 2012-02-18 05:29:29
 * @version��2012-02-18 05:29:29
 */

MagicASP = function( config ) {
	
	var config = ( typeof config === 'undefined' ) ? {} : config ;
	this['config'] = _copy( config, {
		codePage : 65001 , //�����ļ��Ĵ���ҳ Ĭ����UTF-8�Ĵ���ҳ 
		directory : '' , //����֮һ��Ŀ¼ �����Ŀ¼�뱣��Ϊ�� ������� / ���� MagicASP/
		debug : true , //��Ʒ��������Ϊfalse �Ƿ�������ģʽ
		version : 'alpha' , //�汾�������ڲ�ͬ�汾�ĵ���
		logPath :  'logs/' , //��־����·�� ������� / ���� logs/
		accessLog :  true ,// �Ƿ��¼������Ϣ
        scriptFileName : 'index.asp' ,
		siteAddress : 'http://www.example.com/' ,
		redirectAddress : false //404������ת��ַ 
	});	
	
	this['fso'] = new ActiveXObject("Scripting.FileSystemObject");
	this['str'] = $S.CreateObject("ADODB.Stream");
	this['rootPath'] = $S.Mappath('\\' + this['config']['directory'] ) + '\\';
	this['CharSet'] = this['config']['codePage'] == 65001 ? 'utf-8' : 'gbk';
	this['str']['Mode'] = 3;
	this['str']['Type'] = 2;	
	this['str']['CharSet'] = this['CharSet'];

	 //�ж��Ƿ�Log ִ��Log()
	if( this['config']['accessLog'] ) this.log();
	
	$A('scriptURL') = this['config']['siteAddress'] + this['config']['scriptFileName'] ;
    $A('siteAddress') = this['config']['siteAddress'] ;
	
	$R.AddHeader("PoweredBy","MagicASP " + this['Static']['Version']);
	$R.Charset = this['CharSet'];
}


MagicASP.prototype.init = function( moduleList ) {
	
	var mod = m.getSegment(0);
	var act = m.getSegment(1);
	
	this['moduleList'] = moduleList ? moduleList : ['index'] ;	
	this['module'] = mod === false || mod == "" ? 'index' : mod;
	this['action'] = act === false || act == "" ? 'index' : act;
	
	//��ֹ���ļ�����
	if( ( this['action']).match(/\.+/) ) {
		var detail = "This action is unsupported."
		this.throwError( 404, 'UNSUPPORT ACTION', detail); 
	}
	
	//��ֹ����δ�����ģ��
	if( this.arrayIndexOf(this['moduleList'], this['module'] )  === -1 ) {
		this.throwError( 404, 'UNDEFINED MODULE', 'Undefined module.' );
	}
}

MagicASP.prototype.run = function() {
	
	var runFilePath = this['module'] + '_' + this['action'] + '_' + this['config']['version'] + '.asp';
		
	if ( !this['fso']['FolderExists']( this.rootPath + 'runtime\\' ) ) { //����runtimeĿ¼
		this['fso']['CreateFolder']( this.rootPath + 'runtime\\' );
	}
	
	runFilePath = this['rootPath'] + 'runtime\\' + runFilePath;
	
	if( this['config']['debug'] || !this['fso'].FileExists(runFilePath) ) {
					
		var scriptContent = "<% @LANGUAGE=\"VBSCRIPT\" CODEPAGE=\"" + this['config']['codePage'] + "\" %>\r\n";
		//scriptContent += this.addScriptTag( __UTILITY__, "JScript");
		scriptContent += this.include('module\\' + this['module'] + '.asp');
		scriptContent += this.include('action\\' + this['module'] + '\\' + this['action'] + '.asp');
		scriptContent = scriptContent.replace(/MagicASP_INCLUDE_MARK/g , "include");
		this.writeTextFile( runFilePath, scriptContent );

	}
	Server.Execute( runFilePath.replace( Server.Mappath('\\'), '' ) );
}

/*
 * �ļ��������� [MagicASP�ؼ�����]
 * @parameter filepath String �ļ����·�� 
 * @return String �ű����ɵ�����
 */
MagicASP.prototype.include = function( filePath ) {
	
	var fileName,
		scriptContent ,
		fileApplicationName ;

	//Application�����б�����ļ�����
	fileApplicationName = ( filePath.substring( 0, filePath.indexOf('.asp') ) ).split("\\").join("_") ;
	filePath = this['rootPath'] + filePath;
	filePath = filePath.replace(/\//g,"\\");

	if( ( Application(fileApplicationName) !== undefined ) && !this['config']['debug'] ) return Application(fileApplicationName);
		
	try{
		if( this['fso'].FileExists( filePath ) ){
			
			scriptContent = this.readTextFile( filePath );
			//ȥ��ÿ���ļ��� <% RESPONSE.END %>			
			scriptContent = scriptContent.replace(/^<% RESPONSE\.END %>\r\n/, '');

			var self = this ;
			
			//��ԭ�е�include�﷨�����滻 ע��virtual��·��Ϊ��ǰӦ��·�� �Զ������滻
			scriptContent = scriptContent.replace(/<!-{2} ?#include ?virtual=\"(.*)\" ?-->/ig , function( $1, $2 ) {
				return self.include($2);
			});
			
			//��ԭ�е�include�﷨�����滻 file��·��Ϊ��ǰ�ļ�·�� �Զ������滻
			scriptContent = scriptContent.replace(/<!-{2} ?#include ?file=\"(.*)\" ?-->/ig , function( $1, $2 ) { 
				$2 = $2.replace(/\//g,"\\");		
                var currentPath = filePath.replace(self['rootPath'],"");
				currentPath = currentPath.substring(0,currentPath.lastIndexOf("\\"));
				var path = currentPath + "\\" + $2;
				return self.include( path );	
			});
			
            //����require�﷨ ����ԭ����include�﷨ һ�㲻�Ƽ����﷨ ��Ϊ��·����ص� ���׳��� ����ʹ���ڵ���ģʽ
			scriptContent = scriptContent.replace(/<!-{2} ?#require ?file=\"(.*)\" ?-->/ig , function( $1, $2 ) {
                $2 = $2.replace(/\//g,"\\");
				var currentPath = filePath.substring(0,filePath.lastIndexOf("\\"));
				var path = currentPath + "\\" + $2;
				path = self.getTruePath(path);
				path = path.replace($S.MapPath("\\")+"\\","");				
				return "\<\!-- #" + "MagicASP_INCLUDE_MARK " + "virtual=\"" +  path + "\" --\>";
			});

			//����require�﷨ ����ԭ����include�﷨ һ�㲻�Ƽ����﷨ ��Ϊ��·����ص� ���׳��� ����ʹ���ڵ���ģʽ
			scriptContent = scriptContent.replace(/<!-{2} ?#require ?virtual=\"(.*)\" ?-->/ig , function( $1, $2 ) {
                $2 = $2.replace(/\//g,"\\");				
				var currentPath = $S.MapPath("\\") + "\\" + self['config']['directory'];
				var path = currentPath + $2;
				path = self.getTruePath(path);
				path = path.replace($S.MapPath("\\")+"\\","");				
				return "\<\!-- #" + "MagicASP_INCLUDE_MARK " + "virtual=\"" +  path + "\" --\>";
			});
			
			if( this['config']['debug'] ) {
                //Ϊ�˷������ ��λ�����ļ�����
				scriptContent = "\r\n<% '-------- start@:" + filePath + " --------  %>\r\n" + scriptContent + "\r\n<% '-------- end@:" + filePath + " --------  %>\r\n";
			} else {
				//�����Ѿ���ȡ���ļ�
                $A(fileApplicationName) = scriptContent;
            }
			
		} else {
			throw 'FILE_NOT_EXIST';
		}
	} catch( err ) {		
		if(err === 'FILE_NOT_EXIST'){
			var detail = (this['config']['debug'] ? filePath : ' ') + ' file not found ';
			this.throwError( 404 , "FILE NOT FOUND" , detail );
		} else {
			var detail = "Please Contact This Web Master, Thanks!";
			this.throwError( 500 , "CATCH A UNKOWN ERROR" , detail);
		}
	}
	return scriptContent;
}


/*
 * ͨ��ADODB Stream��ȡ�ı��ļ�
 * @parameter filePath String Ҫ��ȡ���ļ�·��
 * @return String �ı�����
 */
MagicASP.prototype.readTextFile = function( filePath ) {
	
	this['str'].Open();	
	this['str'].LoadFromFile( filePath );

	if( this['str']['EOS'] ) {		
		var result = "";
	} else {
		var result = this['str'].ReadText();
		result = result.replace(/^\uFEFF/,'');
	}
	
	this['str'].Close();
	return result;
}

/*
 * ͨ��ADODB Streamд���ı��ļ�
 * @parameter filePath String �ļ�·��
 * @parameter content String д���ı�����
 * @return none
 */ 
MagicASP.prototype.writeTextFile = function( filePath , content ) {

	this['str'].Open();
	
	if ( this['fso'].FileExists( filePath ) ) {
		this['fso'].DeleteFile( filePath );
	}
	
	this['str'].WriteText(content);
	this['str'].SaveToFile(filePath,2);
	this['str'].Flush(); 
	this['str'].Close();
	
}

/*
 * �������
 * @parameter array Array ��Ҫ�����ҵ�����
 * @parameter value String �����ҵ��ַ���
 * @return Number ����λ�� δ�ҵ��򷵻�-1
 */

MagicASP.prototype.arrayIndexOf = function( array , value ) { 
	var len = array.length ;
	if( !len ) return -1;
	for( var i = 0 ; i < len ; i++ )  { if (value == array[i]) return i };
	return -1;
}


/*
 * ��ȡ��ʵ��·��ȥ�� ./ ../
 * @parameter path String ��������ȫ·��
 * @return String ����ȥ��ȫ·��
 */
MagicASP.prototype.getTruePath = function( path ) {

    path = path.replace(/\//g,"\\");
    var arr = path.split("\\");	
    var tmp = [];
    var cur = 0;
    for( var i in arr ) {
        if( arr[i] == ".." ) {
            cur--;			
        } else if( arr[i] != "." ) {
            tmp[cur] = arr[i];
            cur = tmp.length;
        }
    }
    return tmp.join("\\");
}

/*
 * ���ű������ⲿ��ǩ 
 * @parameter scriptContent String �ļ�·��
 * @parameter lang String �ű����� һ����JScript �� VBScript
 * @return �Ӻñ�ǩ֮��Ľű�
 */
MagicASP.prototype.addScriptTag = function( scriptContent, lang ) {
	return '<' + 'script language="'+ lang +'" runat="server">\r\n' + scriptContent + '\r\n<\/script>';
}

/*
 * �׳�������Ϣ
 * @parameter httpCode String HTTP״̬��
 * @parameter title String ��������
 * @parameter detail String ��ϸ������Ϣ
 * @return none
 */
MagicASP.prototype.throwError = function(httpCode, title, detail){
	if( this["config"]["redirectAddress"] !== false ) $R.Redirect( this["config"]["redirectAddress"] );
	Response.Status = ( httpCode + this['Static']['HTTPStatuCode'][httpCode] );
	echo( this.replaceTemplate({
		'httpCode' : httpCode,
		'title' : title,
		'detail' : detail,
		'serverInfo' : String.prototype.concat('MagicASP ',this['Static']['Version'] ,' @ ',server_("Server_Name") ,' ',server_("Server_Software"))
	},this['Static']['errorTemplate']) );
	Response.End();
}

/*
 * HTMLģ���滻
 * @parameter contentArray String �����б�
 * @parameter templateContent String ģ������
 * @return �滻�������
 */
MagicASP.prototype.replaceTemplate = function ( contentObject, templateContent ) {
	for( var k in contentObject ) {
		templateContent = templateContent.replace(new RegExp('\\{\\$'+k+"\\}","ig"), contentObject[k] );
	}
	return templateContent;
}

/*
 * ���û�����д�뵽��־
 */
MagicASP.prototype.log = function() {
	
	var accessLogFile = String.prototype.concat( this['rootPath'] + this['config']['logPath'] + 'access_' , this.getLogFileName() , '.log' );
	var file = this['fso'].OpenTextFile( accessLogFile, 8, true, -1 );	
	
	var logContent = this.replaceTemplate({
		
		remoteIP : server_("REMOTE_ADDR") ,
		time : (new Date()).toLocaleString().replace(/\(.+\)/ig,"") ,
		method : server_("REQUEST_METHOD") ,
		fullPath : get_() == '' ? server_("SCRIPT_NAME") : server_("SCRIPT_NAME")+ '?' + server_("QUERY_STRING") ,
		serverProtocol : server_("REQUEST_METHOD") ,
		referer : _string(server_("HTTP_REFERER")) == 'undefined' ? "" : server_("HTTP_REFERER") ,
		userAgent : server_("HTTP_USER_AGENT")
		
	} , this["Static"]["logTemplate"] );
		
    file.writeLine( logContent )    
    file.close();

}

/*
 * ����ʱ���ȡ��־�ļ��� 
 */
MagicASP.prototype.getLogFileName = function() {
	
	var now = new Date();
    var day = now.getDate();	
    var month = now.getMonth() + 1;
	var year = now.getFullYear();
	
	if( day <= 9 ) day = String.prototype.concat( '0' , day );
	if( month <= 9 ) month = String.prototype.concat( '0' , month );
	
	return String.prototype.concat( year , month , day );
	
}

/*
 * ��̬����
 */
MagicASP.prototype.Static = { 
	
	/*
	 * �׳������ģ��
	 */
	errorTemplate : '<!DOCTYPE HTML>\ 
<html>\
<head>\
	<title>{$httpCode} - {$title}</title>\
	<style>html, body{margin:20px;padding:0;font:13px/22px "Lucida Grande", "Lucida Sans Unicode", Helvetica, Arial, Verdana, sans-serif}</style>\
	<meta http-equiv="Content-Type" content="text/html; charset=gbk">\
</head>\
<body>\
	<fieldset>\
		<h1>{$httpCode} - {$title}</h1>\
		<h2>{$detail}</h2>\
		<div align="right">{$serverInfo}</div>\
	</fieldset>\
</body>\
</html>',

	/*
	 * ��־��¼ģ��
	 */
	logTemplate : '{$remoteIP} [{$time}] "{$method} {$fullPath} {$serverProtocol}" "{$referer}" "{$userAgent}"',
		
	/*
	 * http״̬���¼��
	 */
	HTTPStatuCode : {
		'400' : 'Bad Request',
		'401' : 'Unauthorized',
		'402' : 'Payment Required',
		'403' : 'Forbidden',
		'404' : 'Not Found',
		'405' : 'Method Not Allowed',
		'406' : 'Not Acceptable',
		'407' : 'Proxy Authentication Required',
		'408' : 'Request Timeout',
		'409' : 'Conflict',
		'410' : 'Gone',
		'411' : 'Length Required',
		'412' : 'Precondition Failed',
		'413' : 'Request Entity Too Large',
		'414' : 'Request-URI Too Long',
		'415' : 'Unsupported Media Type',
		'416' : 'Requested Range Not Satisfiable',
		'417' : 'Expectation Failed',
		'500' : 'Internal Server Error',
		'501' : 'Not Implemented',
		'502' : 'Bad Gateway',
		'503' : 'Service Unavailable',
		'504' : 'Gateway Timeout',
		'505' : 'HTTP Version Not Supported'
	} ,

	/*
	 * ��Ʒ�汾��Ϣ
	 */
	Version : 'Beta-2012/02/18'
	
}


</script>