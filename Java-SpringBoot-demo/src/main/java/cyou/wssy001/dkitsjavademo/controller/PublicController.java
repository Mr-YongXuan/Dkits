package cyou.wssy001.dkitsjavademo.controller;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @ProjectName: dkits-java-demo
 * @ClassName: PublicController
 * @Description: 无需验证apiKey以及apiSecret即可请求
 * @Author: alexpetertyler
 * @Date: 2020/12/5
 * @Version v1.0
 */
@RestController
public class PublicController {
    @PostMapping("/DataPort1")
    public String authTest(
            String data
    ) {
        return data;
    }
}
