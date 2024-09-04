package org.b104.alfredo.config;

import org.quartz.spi.TriggerFiredBundle;
import org.springframework.beans.factory.config.AutowireCapableBeanFactory;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.scheduling.quartz.SpringBeanJobFactory;

public class AutowiringSpringBeanJobFactory extends SpringBeanJobFactory implements ApplicationContextAware {

    private transient AutowireCapableBeanFactory beanFactory;
    private transient ApplicationContext applicationContext;

    @Override
    public void setApplicationContext(final ApplicationContext context) {
        this.applicationContext = context;
        this.beanFactory = context.getAutowireCapableBeanFactory();
    }

    @Override
    protected Object createJobInstance(final TriggerFiredBundle bundle) throws Exception {
        final Object job = super.createJobInstance(bundle);
        beanFactory.autowireBean(job);
        if (job instanceof ApplicationContextAware) {
            ((ApplicationContextAware) job).setApplicationContext(applicationContext);
        }
        return job;
    }
}
