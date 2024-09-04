package org.b104.alfredo.config;

import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.spi.JobFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;
import org.springframework.scheduling.quartz.SpringBeanJobFactory;

import java.util.HashMap;
import java.util.Map;

@Configuration
public class QuartzConfig {

    @Autowired
    private ApplicationContext applicationContext;

    @Bean
    public JobFactory jobFactory() {
        SpringBeanJobFactory jobFactory = new AutowiringSpringBeanJobFactory();
        jobFactory.setApplicationContext(applicationContext);
        return jobFactory;
    }

    @Bean
    public SchedulerFactoryBean schedulerFactoryBean() {
        SchedulerFactoryBean schedulerFactoryBean = new SchedulerFactoryBean();

        // ApplicationContext를 Quartz 스케줄러 컨텍스트에 추가
        Map<String, Object> schedulerContextAsMap = new HashMap<>();
        schedulerContextAsMap.put("appContext", applicationContext);
        schedulerFactoryBean.setSchedulerContextAsMap(schedulerContextAsMap);

        // JobFactory 설정
        schedulerFactoryBean.setJobFactory(jobFactory());

        return schedulerFactoryBean;
    }

    @Bean
    public Scheduler scheduler(SchedulerFactoryBean schedulerFactoryBean) throws SchedulerException {
        Scheduler scheduler = schedulerFactoryBean.getScheduler();
        scheduler.start();
        return scheduler;
    }
}
