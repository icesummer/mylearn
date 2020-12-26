# SpringCloud集成Quartz框架实现自定义定时任务(自留记录)

[KimiKudo](https://blog.csdn.net/u010827544) 2020-06-04 14:57:34 ![img](https://csdnimg.cn/release/blogv2/dist/pc/img/articleReadEyes.png) 712 ![img](https://csdnimg.cn/release/blogv2/dist/pc/img/tobarCollect.png) 收藏 4

分类专栏： [学习记录](https://blog.csdn.net/u010827544/category_8651018.html)

版权



### 文章目录

- [需求背景](https://blog.csdn.net/u010827544/article/details/106524607/#_1)
- [实现方案](https://blog.csdn.net/u010827544/article/details/106524607/#_4)
- [实现过程](https://blog.csdn.net/u010827544/article/details/106524607/#_9)
- - [什么是Quartz](https://blog.csdn.net/u010827544/article/details/106524607/#Quartz_10)
  - [添加依赖](https://blog.csdn.net/u010827544/article/details/106524607/#_21)
  - [修改配置](https://blog.csdn.net/u010827544/article/details/106524607/#_31)
  - [添加任务管理类](https://blog.csdn.net/u010827544/article/details/106524607/#_112)
  - [自定义Job](https://blog.csdn.net/u010827544/article/details/106524607/#Job_352)
  - [调用实例](https://blog.csdn.net/u010827544/article/details/106524607/#_415)
- [附录](https://blog.csdn.net/u010827544/article/details/106524607/#_427)



# 需求背景

当前项目中有一个需求是系统消息的定时发送功能,不是很复杂的功能,对比了几种实现方式我还是选择了集成Quartz的方式,因为方便管理和修改,最终也确实实现了我所需的功能,可是过程比较繁琐,特此记录.
参考博客:https://blog.csdn.net/xjy9266/article/details/80947725

# 实现方案

在Spring中实现定时任务大致有三种方式,飞刀,水果刀和宰牛刀

1. Java自带的`Timer`类,优点主要是简单易用吧,缺点应该就是不易集中管理,我称之为**飞刀**,能杀鸡,但是逮不着.
2. SpringBoot自带的TimeTask,也就是`@Schedule`注解实现的方式,优点是同样的简单易用,好配置,但是缺点是不能实现我的自定义定时任务的需求,需要提前配置好.我称之为**水果刀**,能切水果也很轻便,但是不能杀鸡.
3. 第三种就是`Quartz`了.优点是专注于任务调度,方便新增修改删除,可以统一管理,缺点当然是配置繁琐,集成过程操作较多,有杀鸡焉用宰牛刀之嫌,所以我称之为**宰牛刀**,虽然有点重,但是能杀鸡!

# 实现过程

## 什么是Quartz

Quartz是一个任务调度框架,可以有效的实现任务调度的功能,下面是复制的

> Quartz 是一个完全由 Java 编写的开源作业调度框架，为在 Java 应用程序中进行作业调度提供了简单却强大的机制。
> Quartz 可以与 J2EE 与 J2SE 应用程序相结合也可以单独使用。
> Quartz 允许程序开发人员根据时间的间隔来调度作业。
> Quartz 实现了作业和触发器的多对多的关系，还能把多个作业与不同的触发器关联。
> 基本概念:
>
> 1. Job 表示一个工作，要执行的具体内容。此接口中只有一个方法，如下：
> 2. JobDetail 表示一个具体的可执行的调度程序，Job 是这个可执行程调度程序所要执行的内容，另外 JobDetail 还包含了这个任务调度的方案和策略。
> 3. Trigger 代表一个调度参数的配置，什么时候去调。
> 4. Scheduler 代表一个调度容器，一个调度容器中可以注册多个 JobDetail 和 Trigger。当 Trigger 与 JobDetail 组合，就可以被 Scheduler 容器调度了。

## 添加依赖

首先,添加Quartz的依赖

```xml
<!-- 集成quartz -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-quartz</artifactId>
    <version>2.1.6.RELEASE</version>
</dependency>
123456
```

## 修改配置

1. 创建`Job实例工厂`,解决Job中bean无法注入的问题

```java
import org.quartz.spi.TriggerFiredBundle;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.AutowireCapableBeanFactory;
import org.springframework.scheduling.quartz.AdaptableJobFactory;

/**
 * 解决quartz无法注入bean的问题
 * @author Kay
 * 2020-05-15 15:53
 */
public class TaskJobFactory extends AdaptableJobFactory {
    @Autowired
    private AutowireCapableBeanFactory capableBeanFactory;

    @Override
    protected Object createJobInstance(TriggerFiredBundle bundle) throws Exception {
        //调用父类方法
        Object jobInstance = super.createJobInstance(bundle);
        //进行注入
        capableBeanFactory.autowireBean(jobInstance);
        return jobInstance;
    }
}
```

1. 编写`web-quartz.properties`配置文件,放在`classpath`目录下

```
# 固定前缀org.quartz
org.quartz.scheduler.instanceName = DefaultQuartzScheduler
org.quartz.scheduler.instanceId = AUTO 
org.quartz.scheduler.rmi.export = false
org.quartz.scheduler.rmi.proxy = false
org.quartz.scheduler.wrapJobExecutionInUserTransaction = false
123456
```

还有一些其他配置,此处未用到.
\3. 创建`QuartzConfig`类,加载配置文件,从配置文件中读取配置创建一个`SchedulerFactory`的bean,再创建一个`scheduler`的bean

```java
import org.quartz.Scheduler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.config.PropertiesFactoryBean;
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.ClassPathResource;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;

import javax.sql.DataSource;
import java.io.IOException;

/**
 * 任务调度配置
 *
 * @author Kay
 * 2020-05-15 16:49
 */
public class QuartzConfiguration {
    @Autowired
    private DataSource dataSource;

    @Autowired
    private TaskJobFactory jobFactory;

    @Bean(name = "SchedulerFactory")
    public SchedulerFactoryBean schedulerFactoryBean() throws IOException {
        //读取配置文件
        PropertiesFactoryBean propertiesFactoryBean = new PropertiesFactoryBean();
        propertiesFactoryBean.setLocation(new ClassPathResource("/web-quartz.properties"));
        propertiesFactoryBean.afterPropertiesSet();
        //创建SchedulerFactoryBean
        SchedulerFactoryBean factory = new SchedulerFactoryBean();
        factory.setQuartzProperties(propertiesFactoryBean.getObject());
        factory.setJobFactory(jobFactory);
        return factory;
    }

    @Bean(name = "scheduler")
    public Scheduler scheduler() throws IOException {
        return schedulerFactoryBean().getScheduler();
    }
}
1234567891011121314151617181920212223242526272829303132333435363738394041
```

## 添加任务管理类

创建一个`QuartzJobManager`用于对Job进行统一管理,包括创建,修改,暂停,启动,删除等操作
其中使用`@Autowired`注入前面配置类创建的`Scheduler`,使用该调度器来执行操作.
**项目中另一个做数据清洗的子项目也使用了Quartz,那边在操作时同时要指定一下Trigger,我这里没有用,以后再看作用吧**

```java
import com.chinamobile.iot.police.quartz.job.BaseTaskJob;
import lombok.extern.log4j.Log4j2;
import org.quartz.*;
import org.quartz.impl.matchers.GroupMatcher;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * task任务创建个工具类
 *
 * @author Kay
 * 2020-05-15 16:04
 */
@Component
@Log4j2
public class QuartzJobManager {
    private static QuartzJobManager jobUtil;

    @Autowired
    private Scheduler scheduler;

    public QuartzJobManager() {
        log.info("QuartzJobManager init");
        jobUtil = this;
    }

    public static QuartzJobManager getInstance() {
        log.info("return JobUtil");
        return QuartzJobManager.jobUtil;
    }

    /**
     * 创建任务
     *
     * @param clazz          任务类
     * @param jobName        任务名称
     * @param jobGroupName   任务所在组名称
     * @param cronExpression cron表达式
     * @throws Exception
     */
    public void addJob(Class clazz, String jobName, String jobGroupName, String cronExpression) throws Exception {
        //启动调度器
        scheduler.start();
        //构建job信息
        JobDetail jobDetail = JobBuilder.newJob(((BaseTaskJob) clazz.newInstance()).getClass()).withIdentity(jobName, jobGroupName).build();
        //表达式调度构造起,任务执行时间
        CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(cronExpression);
        //根据任务执行时间的cron表达式构建trigger触发器
        CronTrigger trigger = TriggerBuilder.newTrigger().withIdentity(jobName, jobGroupName).withSchedule(scheduleBuilder).build();
        scheduler.scheduleJob(jobDetail, trigger);
    }

    /**
     * 创建job，可传参
     *
     * @param clazz          任务类
     * @param jobName        任务名称
     * @param jobGroupName   任务所在组名称
     * @param cronExpression cron表达式
     * @param argMap         map形式参数
     * @throws Exception
     */
    public void addJob(Class clazz, String jobName, String jobGroupName, String cronExpression, Map<String, Object> argMap) throws Exception {
        // 启动调度器
        scheduler.start();
        //构建job信息
        JobDetail jobDetail = JobBuilder.newJob(((BaseTaskJob) clazz.newInstance()).getClass()).withIdentity(jobName, jobGroupName).build();
        //传入参数
        jobDetail.getJobDataMap().putAll(argMap);
        //表达式调度构建器(即任务执行的时间)
        CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(cronExpression);
        //按新的cronExpression表达式构建一个新的trigger
        CronTrigger trigger = TriggerBuilder.newTrigger().withIdentity(jobName, jobGroupName)
                .withSchedule(scheduleBuilder).build();
        //获得JobDataMap，写入数据
        //trigger.getJobDataMap().putAll(argMap);
        scheduler.scheduleJob(jobDetail, trigger);
    }

    /**
     * 暂停job
     *
     * @param jobName      任务名称
     * @param jobGroupName 任务所在组名称
     * @throws SchedulerException
     */
    public void pauseJob(String jobName, String jobGroupName) throws SchedulerException {
        scheduler.pauseJob(JobKey.jobKey(jobName, jobGroupName));
    }

    /**
     * 恢复job
     *
     * @param jobName      任务名称
     * @param jobGroupName 任务所在组名称
     * @throws SchedulerException
     */
    public void resumeJob(String jobName, String jobGroupName) throws SchedulerException {
        scheduler.resumeJob(JobKey.jobKey(jobName, jobGroupName));
    }


    /**
     * job 更新,只更新频率
     *
     * @param jobName        任务名称
     * @param jobGroupName   任务所在组名称
     * @param cronExpression cron表达式
     * @throws Exception
     */
    public void updateJob(String jobName, String jobGroupName, String cronExpression) throws Exception {
        TriggerKey triggerKey = TriggerKey.triggerKey(jobName, jobGroupName);
        // 表达式调度构建器
        CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(cronExpression);
        CronTrigger trigger = (CronTrigger) scheduler.getTrigger(triggerKey);
        // 按新的cronExpression表达式重新构建trigger
        trigger = trigger.getTriggerBuilder().withIdentity(triggerKey).withSchedule(scheduleBuilder).build();
        // 按新的trigger重新设置job执行
        scheduler.rescheduleJob(triggerKey, trigger);
    }


    /**
     * job 更新,更新频率和参数
     *
     * @param jobName        任务名称
     * @param jobGroupName   任务所在组名称
     * @param cronExpression cron表达式
     * @param argMap         参数
     * @throws Exception
     */
    public void updateJob(String jobName, String jobGroupName, String cronExpression, Map<String, Object> argMap) throws Exception {
        TriggerKey triggerKey = TriggerKey.triggerKey(jobName, jobGroupName);
        // 表达式调度构建器
        CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(cronExpression);
        CronTrigger trigger = (CronTrigger) scheduler.getTrigger(triggerKey);
        // 按新的cronExpression表达式重新构建trigger
        trigger = trigger.getTriggerBuilder().withIdentity(triggerKey).withSchedule(scheduleBuilder).build();
        //修改map
        trigger.getJobDataMap().putAll(argMap);
        // 按新的trigger重新设置job执行
        scheduler.rescheduleJob(triggerKey, trigger);
    }

    /**
     * job 更新,只更新更新参数
     *
     * @param jobName      任务名称
     * @param jobGroupName 任务所在组名称
     * @param argMap       参数
     * @throws Exception
     */
    public void updateJob(String jobName, String jobGroupName, Map<String, Object> argMap) throws Exception {
        TriggerKey triggerKey = TriggerKey.triggerKey(jobName, jobGroupName);
        CronTrigger trigger = (CronTrigger) scheduler.getTrigger(triggerKey);
        //修改map
        trigger.getJobDataMap().putAll(argMap);
        // 按新的trigger重新设置job执行
        scheduler.rescheduleJob(triggerKey, trigger);
    }


    /**
     * job 删除
     *
     * @param jobName      任务名称
     * @param jobGroupName 任务所在组名称
     * @throws Exception
     */
    public void deleteJob(String jobName, String jobGroupName) throws Exception {
        scheduler.pauseTrigger(TriggerKey.triggerKey(jobName, jobGroupName));
        scheduler.unscheduleJob(TriggerKey.triggerKey(jobName, jobGroupName));
        scheduler.deleteJob(JobKey.jobKey(jobName, jobGroupName));
    }


    /**
     * 启动所有定时任务
     */
    public void startAllJobs() {
        try {
            scheduler.start();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 关闭所有定时任务
     */
    public void shutdownAllJobs() {
        try {
            if (!scheduler.isShutdown()) {
                scheduler.shutdown();
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        }


    }

    /**
     * 获取所有任务列表
     *
     * @return
     * @throws SchedulerException
     */
    public List<Map<String, Object>> getAllJob() throws SchedulerException {
        GroupMatcher<JobKey> matcher = GroupMatcher.anyJobGroup();
        Set<JobKey> jobKeys = scheduler.getJobKeys(matcher);
        List<Map<String, Object>> jobList = new ArrayList<>();
        for (JobKey jobKey : jobKeys) {
            List<? extends Trigger> triggers = scheduler.getTriggersOfJob(jobKey);
            for (Trigger trigger : triggers) {
                Map<String, Object> job = new HashMap<>();
                job.put("jobName", jobKey.getName());
                job.put("jobGroupName", jobKey.getGroup());
                job.put("trigger", trigger.getKey());
                Trigger.TriggerState triggerState = scheduler.getTriggerState(trigger.getKey());
                job.put("jobStatus", triggerState.name());
                if (trigger instanceof CronTrigger) {
                    CronTrigger cronTrigger = (CronTrigger) trigger;
                    String cronExpression = cronTrigger.getCronExpression();
                    job.put("cronExpression", cronExpression);
                }
                jobList.add(job);
            }
        }
        return jobList;
    }
}
```

## 自定义Job

创建一个`BaseTaskJob`接口继承`Job`作为自定义`Job`的父接口

```java
import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

/**
 * 基础任务调度接口,新建任务继承此接口
 * @author Kay
 * 2020-05-15 16:13
 */
public interface BaseTaskJob extends Job {
    @Override
    void execute(JobExecutionContext context) throws JobExecutionException;
}
12345678910111213
```

自定义一个系统消息的Job,实现系统消息发送功能,因为发送功能是需要系统消息ID来操作数据库的,所以这里需要通过`JobDataMap`来传参数的.

```java
import com.chinamobile.iot.police.common.BusinessException;
import com.chinamobile.iot.police.quartz.config.QuartzJobManager;
import com.chinamobile.iot.police.service.personal.MessageService;
import lombok.extern.log4j.Log4j2;
import org.quartz.JobDataMap;
import org.quartz.JobDetail;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * 系统消息的任务调度类
 *
 * @author Kay
 * 2020-05-15 17:25
 */
@Component
@Log4j2
public class MessageQuartz implements BaseTaskJob {


    @Autowired
    private MessageService messageService;

    @Override
    public void execute(JobExecutionContext context) throws JobExecutionException {
        JobDataMap jobDataMap = context.getJobDetail().getJobDataMap();
        Long messageId = jobDataMap.getLong("messageId");
        //log.info("messageId>>>>>>>>>>>" + messageId);
        if (messageId == null) {
            log.error("定时发送有误,未指定系统消息ID");
            throw new BusinessException("定时发送失败");
        }
        messageService.sendMessage(messageId);
        try {
            //执行之后删除此定时任务
            QuartzJobManager.getInstance().deleteJob("message-" + messageId, "message");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
12345678910111213141516171819202122232425262728293031323334353637383940414243
```

## 调用实例

完成以上内容之后,就能在业务中使用`QuartzJobManager`进行任务的创建,修改,删除等操作了,
看下面这个例子,是我业务中,在新增系统消息时,根据参数判断是否是定时发送的,是的话,就新建一个`MessageQuartz`的任务,将发送时间进行格式化为`cron表达式`,创建一次性的定时发送任务

```java
Map<String, Object> jobDataMap = new HashMap<>();
//messageId作为job参数
jobDataMap.put("messageId", messageId);
//将日期改为cron表达式
String cron = DateCronUtil.dateToCron(messageSend.getSendTime());
QuartzJobManager.getInstance().addJob(MessageQuartz.class, "message-" + messageId,"message", cron, jobDataMap);
123456
```

# 附录

日期转cron表达式的工具类

```java
import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * Date-Cron表达式转化工具类
 * Quartz模块使用
 *
 * @author Kay
 * 2020-05-18 9:19
 */
public class DateCronUtil {
    public static String dateToCron(Date date) {
        SimpleDateFormat format = new SimpleDateFormat("ss mm HH dd MM ? yyyy");
        return format.format(date);
    }
}
```

