
<%@ page import="java.sql.*" %>

<html>
<head>
    <title>Vaccination Records</title>

    <script>
    function validateSearch() {
        let name = document.getElementById("search").value;

        if (name !== "" && !/^[a-zA-Z ]+$/.test(name)) {
            alert("Invalid Name! Enter alphabets only.");
            return false;
        }

        return true;
    }
    </script>
</head>

<body>

<h2>Vaccination Records</h2>

<form action="result.jsp" method="get"
      onsubmit="return validateSearch()">

    <input type="text" id="search" name="search"
           placeholder="Child Name">

    <input type="submit" value="Search">
</form>

<%
String dbPassword = "root123";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");

    Connection con = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/vaccination_db",
        "root",
        dbPassword
    );

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        String name = request.getParameter("child_name");
        String vaccine = request.getParameter("vaccine");
        String date = request.getParameter("vaccinated_on");
        String hospital = request.getParameter("hospital");

        if (name != null && vaccine != null &&
            date != null && hospital != null) {

            String sql = "INSERT INTO vaccination " +
                "(child_name, vaccine, vaccinated_on, hospital) " +
                "VALUES (?, ?, ?, ?)";

            PreparedStatement insert = con.prepareStatement(sql);

            insert.setString(1, name);
            insert.setString(2, vaccine);
            insert.setDate(3, Date.valueOf(date));
            insert.setString(4, hospital);

            insert.executeUpdate();
            insert.close();
        }
    }

    String search = request.getParameter("search");

    PreparedStatement p;

    if (search == null || search.trim().isEmpty()) {
        p = con.prepareStatement("SELECT * FROM vaccination");
    } else {
        p = con.prepareStatement(
            "SELECT * FROM vaccination WHERE child_name LIKE ?"
        );
        p.setString(1, "%" + search.trim() + "%");
    }

    ResultSet r = p.executeQuery();
%>

<table border="1" cellpadding="8">
<tr>
    <th>ID</th>
    <th>Child Name</th>
    <th>Vaccine</th>
    <th>Date</th>
    <th>Hospital</th>
</tr>

<%
    while (r.next()) {
%>
<tr>
    <td><%= r.getInt("id") %></td>
    <td><%= r.getString("child_name") %></td>
    <td><%= r.getString("vaccine") %></td>
    <td><%= r.getDate("vaccinated_on") %></td>
    <td><%= r.getString("hospital") %></td>
</tr>
<%
    }

    r.close();
    p.close();
    con.close();

} catch (Exception e) {
    out.println("<p>Error: " + e.getMessage() + "</p>");
}
%>

</table>

</body>
</html>
