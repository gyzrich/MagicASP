<%
	Response.Write "<h1>�����ʵ�ʻ�����index.asp�������ĵ�MagicASP��лл������</h1>"
	Response.Write "<h1>�������֮����ɾ�����δ��룡</h1>"
	Response.End
%>
<!-- #include file="lib/MagicASP.asp" -->
<script Language="JavaScript" RunAt="Server">
/*
 * MagicASP
 * @version: beta
 * @author: qpwoeiru96
 * @link: http://sou.la/blog
 * @date: 2012-02-18
 * @description: 
 *    �����ļ������Ŀ¼��ΪĬ��Ŀ¼ �½��ļ��� module action runtime logs module���潨��index.asp  action���潨��index�ļ��в��������潨��index.asp ����
 *    Ȼ������һ�µ����ݣ�����������
 */
app = new MagicASP({
	codePage : 936 , //�����ļ��Ĵ���ҳ Ĭ����UTF-8�Ĵ���ҳ ������936 ΪGBK UTF-8����65001 
	directory : '' , //����֮һ��Ŀ¼ �����Ŀ¼�뱣��Ϊ�� ������� / ���� MagicASP/
	debug : true , //��Ʒ��������Ϊfalse �Ƿ�������ģʽ
	version : 'beta' , //�汾�������ڲ�ͬ�汾�ĵ���
	logPath :  'logs/' , //��־����·�� ������� / ���� logs/
	accessLog : true ,// �Ƿ��¼������Ϣ
	scriptFileName : '' ,//վ��ű��ļ� һ����index.asp  ����URL����
	siteAddress : 'http://www.example.com/', //վ���ַ ����URL����
    redirectAddress : false //404������ת��ַ  ���ڳ���ʱֱ����ת��ҳ�������ʾ����
});
app.init(['index']); //��ִ�� module �б�
app.run();
</script>