package cyou.wssy001.dkitsjavademo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;

@SpringBootApplication(exclude = DataSourceAutoConfiguration.class)
public class DkitsJavaDemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DkitsJavaDemoApplication.class, args);
    }

}
