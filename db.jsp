<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" import="java.io.*, java.net.*, java.sql.*, com.google.gson.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>DB 저장 완료</title>
</head>
<body>

<%
    
    final String DB_URL = "jdbc:mysql://localhost:3306/naverdb?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF8";
    final String USER = "root";   
    final String PASS = "1234";  

    String clientId = ""; 
    String clientSecret = ""; 

    
    request.setCharacterEncoding("UTF-8");
    String keyword = request.getParameter("keyword");

    int display = 10;   
    int maxTotal = 100; 
    int savedCount = 0; 

    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        out.println("<h3>❌ MySQL 드라이버 로드 실패</h3>");
    }

    
    String sql = "INSERT INTO naver_api_results (search_keyword, item_rank, title, link, description, reg_date) VALUES (?, ?, ?, ?, ?, NOW())";

    try (Connection conn = DriverManager.getConnection(DB_URL, USER, PASS);
         PreparedStatement pstmt = conn.prepareStatement(sql)) {

        
        for (int curPage = 1; curPage <= (maxTotal / display); curPage++) {
            if (savedCount >= maxTotal) break;

            int start = (curPage - 1) * display + 1;
            String query = URLEncoder.encode(keyword, "UTF-8");
            String apiURL = "https://openapi.naver.com/v1/search/doc.json?query=" + query
                + "&display=" + display + "&start=" + start;

            URL url = new URL(apiURL);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setRequestMethod("GET");
            con.setRequestProperty("X-Naver-Client-Id", clientId);
            con.setRequestProperty("X-Naver-Client-Secret", clientSecret);

            int responseCode = con.getResponseCode();
            
            if (responseCode == 200) {
                try (BufferedReader br = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"))) {
                    Gson gson = new Gson();
                    JsonObject json = gson.fromJson(br, JsonObject.class);
                    JsonArray items = json.getAsJsonArray("items");
                    
                    if (items != null) {
                        int itemRankBase = start - 1;

                        for (JsonElement e : items) {
                            if (savedCount >= maxTotal) break;
                            
                            JsonObject item = e.getAsJsonObject();
                            String title = item.get("title").getAsString().replaceAll("<(/)?b>", ""); 
                            String link = item.get("link").getAsString();
                            String desc = item.get("description").getAsString().replaceAll("<(/)?b>", ""); 
                            
                            pstmt.setString(1, keyword); 
                            pstmt.setInt(2, itemRankBase + items.asList().indexOf(e) + 1); 
                            pstmt.setString(3, title);
                            pstmt.setString(4, link);
                            pstmt.setString(5, desc);
                            
                            pstmt.executeUpdate(); 
                            savedCount++;
                        }
                    }
                }
            } else {
                out.println("<h3>❌ API 요청 실패 (응답 코드: " + responseCode + ")</h3>");
                break; 
            }
            con.disconnect();
        }
        
        
        out.println("<h1>✅ DB 저장 완료</h1>");
        if (savedCount > 0) {
            out.println("<p>검색어 '" + keyword + "'에 대한 API 결과 " + savedCount + "건이 성공적으로 저장되었습니다.</p>");
        } else {
             out.println("<p>저장할 데이터가 없거나, API 호출에 실패했습니다.</p>");
        }
        
        out.println("<p><a href='result.jsp?keyword=" + URLEncoder.encode(keyword, "UTF-8") + "'>검색 결과 페이지로 돌아가기</a></p>");


    } catch (SQLException e) {
        out.println("<h2>❌ DB 연결 또는 저장 중 오류 발생</h2>");
        out.println("<p>오류 메시지: " + e.getMessage() + "</p>");
    } catch (Exception e) {
        out.println("<h2>❌ API 호출 또는 기타 오류 발생</h2>");
        out.println("<p>오류 메시지: " + e.getMessage() + "</p>");
    }
%>

</body>

</html>
