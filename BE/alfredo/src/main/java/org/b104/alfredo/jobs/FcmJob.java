package org.b104.alfredo.jobs;


import org.b104.alfredo.config.ApplicationContextProvider;
import org.b104.alfredo.firebase.service.FCMAlarmService;
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.quartz.SchedulerException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.scheduling.quartz.QuartzJobBean;
import org.springframework.stereotype.Component;
import org.springframework.web.context.support.SpringBeanAutowiringSupport;

import java.io.IOException;


public class FcmJob extends QuartzJobBean {

    // 이 방식은 틀린 방식이다
    // public class FcmJob implements Job, ApplicationContextAware
    // quartz job에서는 service를 호출하면 null이 나오기 때뮨에 job과 task를 분리 해야 한다
//    @Autowired
//    private FCMAlarmService fcmAlarmService;
//
////    public FcmJob() {
////    }
////
////
////    public FcmJob(FCMAlarmService fcmAlarmService) {
////        this.fcmAlarmService = fcmAlarmService;
////        System.out.println("FcmJob this called");
////    }
//
//    @Override
//    public void execute(JobExecutionContext context) throws JobExecutionException {
////        SpringBeanAutowiringSupport.processInjectionBasedOnCurrentContext(this);
//        String targetToken = context.getJobDetail().getJobDataMap().getString("targetToken");
//        String title = context.getJobDetail().getJobDataMap().getString("title");
//        String body = context.getJobDetail().getJobDataMap().getString("body");
//        System.out.println("in job");
//        System.out.println(targetToken);
//        System.out.println(title);
//        System.out.println(body);
//        try {
//            fcmAlarmService.sendMessageTo(targetToken, title, body);  // FCM 메시지 전송 메소드 호출
//        } catch (Exception e) {
//            throw new JobExecutionException(e);
//        }
//    }
    // ApplicationContext을 사용해서 null을 벗어나려고 햇지만 여전히 실패
    // public class FcmJob implements Job, ApplicationContextAware
//    private transient ApplicationContext applicationContext;
//
//    @Override
//    public void setApplicationContext(ApplicationContext applicationContext) {
//        this.applicationContext = applicationContext;
//    }
//
//    @Override
//    public void execute(JobExecutionContext context) throws JobExecutionException {
//        FcmTask fcmTask = applicationContext.getBean(FcmTask.class);
//        fcmTask.run(context);
//    }
    @Override
    protected void executeInternal(JobExecutionContext context) throws JobExecutionException {
        try {
            ApplicationContext appContext = (ApplicationContext) context.getScheduler().getContext().get("appContext");
            if (appContext == null) {
                System.out.println("Trying to get ApplicationContext from ApplicationContextProvider as fallback.");
                appContext = ApplicationContextProvider.getApplicationContext();
                if (appContext == null) {
                    throw new JobExecutionException("ApplicationContext is not available in job context or ApplicationContextProvider.");
                }
            }

            FCMAlarmService fcmService = appContext.getBean(FCMAlarmService.class);
            String targetToken = context.getMergedJobDataMap().getString("targetToken");
            String title = context.getMergedJobDataMap().getString("title");
            String body = context.getMergedJobDataMap().getString("body");

            fcmService.sendMessageTo(targetToken, title, body);
        } catch (Exception e) {
            throw new JobExecutionException("Error retrieving ApplicationContext or sending FCM message.", e);
        }
    }

}
