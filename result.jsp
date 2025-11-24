<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.io.*, java.net.*, com.google.gson.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>네이버 전문자료 통합 검색</title>
</head>
<body>

<h2>네이버 전문자료 통합 검색</h2>

<form action="" method="get">
    <label>검색어 :</label>
    <input type="text" name="keyword" 
           value="<%= (request.getParameter("keyword") != null ? request.getParameter("keyword") : "") %>" 
           required>
    <button type="submit">검색</button>
</form>

<hr>

<%
    request.setCharacterEncoding("UTF-8");
    String keyword = request.getParameter("keyword");

    // ==========================================================
    // API 로직 시작
    
    // 키워드가 null이 아니고 공백이 아닐 때만 API 검색 로직을 실행
    if (keyword != null && !keyword.trim().isEmpty()) {
        
    	//==========API키 입력==============
        String clientId = "    ";
        String clientSecret = "    ";
        //==========API키 입력==============
        		
        String query = URLEncoder.encode(keyword, "UTF-8");

        String apiURL = "https://openapi.naver.com/v1/search/doc.json?query=" + query + "&display=10";//"&display=10" : 10개씩 출력

        // API 연동 (HttpURLConnection) 시작 
        URL url = new URL(apiURL);
        HttpURLConnection con = (HttpURLConnection) url.openConnection();
        con.setRequestMethod("GET");

        con.setRequestProperty("X-Naver-Client-Id", clientId);
        con.setRequestProperty("X-Naver-Client-Secret", clientSecret);

        // 응답 수신 및 JSON 파싱 
        BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));

        Gson gson = new Gson();
        JsonObject json = gson.fromJson(br, JsonObject.class);
        JsonArray items = json.getAsJsonArray("items");
        // API 연동 및 파싱 영역 끝

	// ==========================================================
	// API 로직 끝

%>


<table border="1" cellspacing="0" cellpadding="7">
    <tr>
        <th>제목</th>
        <th>링크</th>
        <th>설명</th>
    </tr>

<%
    // 결과 목록을 HTML 표로 출력하는 부분
    // 표의 구조(<tr>, <td>)는 디자인에 따라 변경 가능
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

<%
    } // if (keyword != null && !keyword.trim().isEmpty()) 닫는 부분
%>

</body>
</html>
