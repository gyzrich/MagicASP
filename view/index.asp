<!-- #include file="common/header.asp" -->
<p>ͨ���Դ��������ɵ�URLΪ:<% = m.cu(m.seg("news","read","3"),m.kv("page","3")) %></p>
<p><a href="<% = m.cu(m.seg("index","index","test"),m.kv("welcome","")) %>">����������</a></p>
<p>url�ĵ�1��Ϊ��<% = m.gs(0) %></p>
<p>url�ĵ�2��Ϊ��<% = m.gs(1) %></p>
<% if( vartype( m.gs(2) ) <> 11 ) then %>
<p>url�ĵ�3��Ϊ��<% = m.gs(2) %></p>
<% end if %>
<p>��Ŀ¼�ǣ�<%=m.root()%></p>
<p>���������ļ�:<%=m.root("images/MagicASP-Logo.png")%></p>
<div>
	<form action="<% = m.cu(m.seg("news"),m.kv("page","3")) %>" method="get">
	<input name="test" type="text" value="test"><input type="submit">
	<% m.fgm(m.seg("index","index")) : '�˴������޸�get��ʽ�ύ���� %>
	</form>
</div>

�����Ǵ�ҳ��Դ����
<pre style="font-size:12px;">

&lt;!-- #include file="common/header.asp" --&gt;
&lt;p&gt;ͨ���Դ��������ɵ�URLΪ:&lt;% = m.cu(m.seg("news","read","3"),m.kv("page","3")) %&gt;&lt;/p&gt;
&lt;p&gt;&lt;a href="&lt;% = m.cu(m.seg("index","index","test"),m.kv("welcome","")) %&gt;"&gt;����������&lt;/a&gt;&lt;/p&gt;
&lt;p&gt;url�ĵ�1��Ϊ��&lt;% = m.gs(0) %&gt;&lt;/p&gt;
&lt;p&gt;url�ĵ�2��Ϊ��&lt;% = m.gs(1) %&gt;&lt;/p&gt;
&lt;% if( vartype( m.gs(2) ) &lt;&gt; 11 ) then %&gt;
&lt;p&gt;url�ĵ�3��Ϊ��&lt;% = m.gs(2) %&gt;&lt;/p&gt;
&lt;% end if %&gt;
&lt;p&gt;��Ŀ¼�ǣ�&lt;%=m.root()%&gt;&lt;/p&gt;
&lt;p&gt;���������ļ�:&lt;%=m.root("images/MagicASP-Logo.png")%&gt;&lt;/p&gt;
&lt;div&gt;
	&lt;form action="&lt;% = m.cu(m.seg("news"),m.kv("page","3")) %&gt;" method="get"&gt;
	&lt;input name="test" type="text" value="test"&gt;&lt;input type="submit"&gt;
	&lt;% m.fgm(m.seg("index","index")) : '�˴������޸�get��ʽ�ύ���� %&gt;
	&lt;/form&gt;
&lt;/div&gt;
&lt;!-- #include file="common/footer.asp" --&gt;

</pre>
<!-- #include file="common/footer.asp" -->