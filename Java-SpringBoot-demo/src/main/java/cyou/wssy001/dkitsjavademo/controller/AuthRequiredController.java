package cyou.wssy001.dkitsjavademo.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @ProjectName: dkits-java-demo
 * @ClassName: AuthRequiredController
 * @Description: 需要验证apiKey以及apiSecret才可请求
 * @Author: alexpetertyler
 * @Date: 2020/12/5
 * @Version v1.0
 */
@RestController
public class AuthRequiredController {
    @PostMapping("/auth/DataPort1")
    public String authTest(
            String data
    ) {
        return data;
    }
}
