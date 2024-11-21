import org.postgresql.PGConnection;
import org.postgresql.PGNotification;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class Main {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://localhost:5432/test";
        String user = "postgres";
        String password = "admin";

        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            // Converter a conexão JDBC em PGConnection
            PGConnection pgConnection = conn.unwrap(PGConnection.class);

            // Configurar a escuta para o canal de notificação
            try (Statement stmt = conn.createStatement()) {
                stmt.execute("LISTEN meu_canal");
                System.out.println("Escutando notificações no canal: 'meu_canal'");
            }

            while (true) {
                // Verificar notificações
                PGNotification[] notifications = pgConnection.getNotifications();
                if (notifications != null) {
                    for (PGNotification notification : notifications) {
                        System.out.printf("Recebida notificação: %s - %s%n",
                                notification.getName(),
                                notification.getParameter());
                    }
                }

                // Aguarde um momento antes de verificar novamente
                Thread.sleep(1000);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
