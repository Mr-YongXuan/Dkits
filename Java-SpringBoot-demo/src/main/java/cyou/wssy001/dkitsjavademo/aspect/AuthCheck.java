package cyou.wssy001.dkitsjavademo.aspect;

import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;
import java.util.Objects;

/**
 * @ProjectName: dkits-java-demo
 * @ClassName: AuthCheck
 * @Description: API请求鉴权的切面
 * @Author: alexpetertyler
 * @Date: 2020/12/5
 * @Version v1.0
 */
@Aspect
@Component
@Slf4j
public class AuthCheck {
    @Pointcut("execution(* cyou.wssy001.dkitsjavademo.controller.AuthRequiredController.*(..))")
    public void authCheck() {
    }

    @Before("authCheck()")
    public void authCheck(JoinPoint point) throws Exception {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        HttpServletRequest request = Objects.requireNonNull(attributes).getRequest();
        Map<String, String[]> parameterMap = request.getParameterMap();
        if (!parameterMap.containsKey("apikey") || parameterMap.containsKey("apisec"))
            throw new Exception("请检查apiKey，apiSec是否正确传入");

        String apikey = parameterMap.get("apikey")[0];
        String apisec = parameterMap.get("apisec")[0];
        if (StringUtils.isEmpty(apikey) || StringUtils.isEmpty(apisec))
            throw new Exception("请检查apiKey，apiSec是否正确输入");

//        通过传入的apiKey,apiSec进行进一步的权限校验
    }
}
