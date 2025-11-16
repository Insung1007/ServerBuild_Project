<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.io.*, java.net.*, com.google.gson.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>검색 결과</title>
</head>
<body>
<%
    request.setCharacterEncoding("UTF-8");
    String keyword = request.getParameter("keyword");

    // ********** 본인 API 발급 후 해당 칸에 기입 **********
    String clientId = "여기에 클라이언트 ID 기입";
    String clientSecret = "클라이언트 Secret 기입";
  	// ********** 본인 API 발급 후 해당 칸에 기입 **********
  	
    String query = URLEncoder.encode(keyword, "UTF-8");

    String apiURL = "https://openapi.naver.com/v1/search/doc.json?query=" + query + "&display=10";

    URL url = new URL(apiURL);
    HttpURLConnection con = (HttpURLConnection) url.openConnection();
    con.setRequestMethod("GET");

    con.setRequestProperty("X-Naver-Client-Id", clientId);
    con.setRequestProperty("X-Naver-Client-Secret", clientSecret);

    BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));

    Gson gson = new Gson();
    JsonObject json = gson.fromJson(br, JsonObject.class);

    JsonArray items = json.getAsJsonArray("items");
%>

<h2>검색 결과 (전문자료)</h2><p>
<strong>검색어:</strong> <%= keyword %></p>

<table border="1" cellspacing="0" cellpadding="7">
    <tr>
        <th>제목</th>
        <th>링크</th>
        <th>설명</th>
    </tr>

<%
    for (JsonElement e : items) {
        JsonObject item = e.getAsJsonObject();
        String title = item.get("title").getAsString();
        String link = item.get("link").getAsString();
        String desc = item.get("description").getAsString();
%>
    <tr>
        <td><%= title %></td>
        <td><a href="<%= link %>" target="_blank">바로가기</a></td>
        <td><%= desc %></td>
    </tr>
<%
    }
%>

</table>

<br><br>
<a href="index.jsp">다시 검색하기</a>
</body>
</html>