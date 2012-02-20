<script Language="JavaScript" RunAt="Server">
/*
 * MagicASP ���߼�
 */

var $S = Server ,
    $Q = Request,
    $R = Response,
    $A = Application;



_string = function(a) {
	if( typeof a == "undefined" ) {
		return '';
	}
	return new String( a );
}

_number = function() {
	return new Number( arguments[0] );
}


echo = function() { //ģ��PHP echo
	for( var i = 0 ; i < arguments.length ; i++ ) {
		$R.Write( arguments[i] );
	}
}

_copy = function( source , target ) { //����ǳ��ο���
	for( var key in source ) {
		target[key] = source[key] ;
	}	
	return target;
}

server_ = function(a) {
	return $Q.ServerVariables( a ) ;
}

cookie_ = function(a) {
    return $Q.Cookies(a);
}

get_ = function() {
	return arguments.length == 0 ? $Q.QueryString() : $Q.QueryString( arguments[0] ) ;
}

post_ = function(a) {
    return _Q.Form( a );
}

MagicASP_Utility = {
	
	kv : function( a, b ) {//������VBScript�Լ�JScript���õ����ݸ�ʽ
		return [a,b];
	},
		
	getSegment : function(id) { //��ȡ·���ֶεĺ��� getSegment ���Ծͷ���false ע����false ����vartype = 11�ж��Ƿ���
	
		var segs = _string(get_("_"));		
		var arr = segs.length == 0 || segs == 'undefined' ? [] : segs.match(/[^\/]+/g);	
		
		if( id > arr.length - 1 ) {
			return false;
		} else {
			return arr[id];
		}
	
	},
	
	segments : function() { //�����ֶ� Ҳ�����Լ����� 
	
		var seg = "";
		for( var i = 0 ; i < arguments.length ; i++ ) {
			seg += String.prototype.concat ( $S.URLEncode(arguments[i]) + '/' );
		}
		return seg;
	
	},
	
	createUrl : function( segments ) { //����URL 
		
		var qs = '?_=' +  segments;
		
		for(var i = 1; i < arguments.length ; i++)
		{
			var arr = arguments[i];
			qs += "&" + $S.URLEncode(arr[0]) + "=" + $S.URLEncode(arr[1]);
		}
		return $A('scriptURL') + qs;
	},
	
	root : function() {
        return String.prototype.concat( $A('siteAddress') + (arguments.length !== 0 ? arguments[0] : "")  );
    },
	
	fixGETMethod : function( segments ) { //����Form
		echo('<input type="hidden" name="_" value="'+segments+'"/>');
	}
}

m = MagicASP_Utility;
m.cu = m.createUrl;
m.fgm = m.fixGETMethod;
m.seg = m.segments;
m.gs = m.getSegment;

</script>