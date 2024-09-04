package org.b104.alfredo.jobs.service;

import org.quartz.*;
import org.quartz.impl.matchers.GroupMatcher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

@Service
public class JobService {
    @Autowired
    private Scheduler scheduler;

    // 아직 실행되지 않은 트리거와 관련 Job들의 정보를 조회
    public List<String> getPendingJobs() throws SchedulerException {
        List<String> pendingJobs = new ArrayList<>();
        for (String groupName : scheduler.getJobGroupNames()) {
            for (JobKey jobKey : scheduler.getJobKeys(GroupMatcher.jobGroupEquals(groupName))) {
                List<? extends Trigger> triggers = scheduler.getTriggersOfJob(jobKey);
                for (Trigger trigger : triggers) {
                    if (trigger.getNextFireTime() != null && trigger.getNextFireTime().after(new Date())) {
                        pendingJobs.add(jobKey.getName() + " will run at: " + trigger.getNextFireTime());
                    }
                }
            }
        }
        return pendingJobs;
    }
}
