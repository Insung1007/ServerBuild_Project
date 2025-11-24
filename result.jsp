<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.io.*, java.net.*, com.google.gson.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>네이버 전문자료 통합 검색</title>
  <style>
    table {
        border-collapse: collapse; /* cellspacing=0 효과 */
        width: 100%;
    }
    table th, table td {
        padding: 7px; /* cellpadding=7 효과 */
        border: 1px solid #000;
        vertical-align: top;
    }
    .pagination a, .pagination strong {
        padding: 5px 10px;
        margin: 0 2px;
        border: 1px solid #ccc;
        text-decoration: none;
        display: inline-block;
    }
    .pagination strong {
        background-color: #007bff;
        color: white;
        border-color: #007bff;
    }
  </style>
</head>
<body>
  <h2>네이버 전문자료 통합 검색</h2>
  <form method="get">
    <label>검색어 :</label>
    <input type="text" name="keyword"
      value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>"
      required>
    <button type="submit">검색</button>
  </form>
  <hr>

<%
  request.setCharacterEncoding("UTF-8");
  String keyword = request.getParameter("keyword");
  
  if (keyword != null && !keyword.trim().isEmpty()) {
 
    // API 인증 정보 및 페이징 변수 설정
    String clientId = "qjXA6noEF39SPOkVulXB";
    String clientSecret = "_EsP17fZuR"; // 정확한 Secret으로 수정 필요
    
    int display = 10;  // 한 페이지당 10개 보여주기
    int curPage = 1;
    
    if (request.getParameter("page") != null) {
      try {
        curPage = Integer.parseInt(request.getParameter("page"));
      } catch (NumberFormatException e) {
        curPage = 1;
      }
    }
    if (curPage < 1) curPage = 1;

    // API 요청 시작 위치 계산 (1, 11, 21...)
    int start = (curPage - 1) * display + 1;

   
    // API URL 구성 (query, display, start 포함)
    String query = URLEncoder.encode(keyword, "UTF-8");
    String apiURL = "https://openapi.naver.com/v1/search/doc.json?query=" + query
      + "&display=" + display + "&start=" + start;

    URL url = null;
    HttpURLConnection con = null;
    BufferedReader br = null;
    
    JsonArray items = null;
    int totalResults = 0; // 총 검색 결과 수를 저장할 변수

    try {
      // new URL(String) Deprecated 경고 무시
      url = new URL(apiURL); 
      con = (HttpURLConnection) url.openConnection();
      con.setRequestMethod("GET");
      con.setRequestProperty("X-Naver-Client-Id", clientId);
      con.setRequestProperty("X-Naver-Client-Secret", clientSecret);

      int responseCode = con.getResponseCode();
      
      // 응답 처리 및 JSON 파싱
      if (responseCode == 200) {
        br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
      } else {
        // 오류 발생 시 디버깅을 위해 에러 스트림 내용을 출력
        br = new BufferedReader(new InputStreamReader(con.getErrorStream(), "UTF-8"));
        StringBuilder errorResponse = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            errorResponse.append(line);
        }
        out.println("<h3>API 요청 실패 (응답 코드: " + responseCode + ")</h3>");
        out.println("<p>상세 오류: " + errorResponse.toString() + "</p>");
        br.close(); 
        br = null;
      }

      if (br != null) {
        Gson gson = new Gson();
        JsonObject json = gson.fromJson(br, JsonObject.class);
        items = json.getAsJsonArray("items");
        
        // 총 검색 결과 수 (total)를 받아와 페이징 계산에 사용
        if (json != null && json.has("total")) {
            totalResults = json.get("total").getAsInt();
        }
      }

    } catch (Exception e) {
      out.println("API 호출 중 예외 발생: " + e.getMessage());
    } finally {
      // Resource Leak 경고 방지, finally 블록에서 리소스 해제
      if (br != null) {
        try { br.close(); } catch (IOException ignored) {}
      }
      if (con != null) {
        con.disconnect();
      }
    }

    if (items != null) {
%>

  <table border="1" style="border-collapse: collapse;">
    <tr>
      <th>번호</th>
      <th>제목</th>
      <th>링크</th>
      <th>설명</th>
    </tr>
<%
      // 현재 페이지의 시작 번호
      int itemNum = start; 

      for (JsonElement e : items) {
        JsonObject item = e.getAsJsonObject();
        String title = item.get("title").getAsString();
        String link = item.get("link").getAsString();
        String desc = item.get("description").getAsString();
%>
    <tr>
      <td><%= itemNum++ %></td> <td><%= title %></td>
      <td><a href="<%= link %>" target="_blank">바로가기</a></td>
      <td><%= desc %></td>
    </tr>
<%
      }
%>
  </table>

  <p>페이지: 
<%
      // Math.min(totalResults, 100)으로 최대 100개까지만 페이지를 계산
      int maxPages = (int) Math.ceil((double) Math.min(totalResults, 100) / display);
      if (maxPages == 0 && totalResults > 0) maxPages = 1; // 검색 결과는 있으나 10개 미만일 때 1페이지 표시
      if (maxPages == 0 && totalResults == 0) maxPages = 0; // 결과가 아예 없을 때는 페이지 표시 안함

      for (int i = 1; i <= maxPages; i++) {
        if (i == curPage) {
          out.print("<strong>" + i + "</strong> ");
        } else {
          out.print("<a href=\"?keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&page=" + i + "\">" + i + "</a> ");
        }
      }
%>
  </p>

<%
    } 
  } 
%>

</body>
</html>

