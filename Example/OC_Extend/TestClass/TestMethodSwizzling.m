//
//  TestMethodSwizzling.m
//  OC_Extend_Example
//
//  Created by 红军张 on 2018/6/6.
//  Copyright © 2018年 zhj1214. All rights reserved.
//

#import "TestMethodSwizzling.h"

@implementation TestMethodSwizzling


/**
 打印所有的注册 类

 unsigned int outCount = 0;
 Class *classes = objc_copyClassList(&outCount);
 for (int i = 0; i < outCount; i++) {
 NSLog(@"%s", class_getName(classes[i]));
 }
 free(classes);
 */
#pragma mark -- 获取指定类的类名 (char *类型字符串)
+(void)getClassObjectName {
    //    cls: 类型
    //    返回值: 类名 - char *类型的字符串
    const char *name = class_getName([Person class]);
    NSLog(@"获取自定义类的类名：%s",name);
}

#pragma mark -- 获取指定类的父类型 (Class类型)
+(void)getSuperClassObjectName {
    //    cls: 类型
    //    返回值: 父类型 Class类型
    Class class = class_getSuperclass([Person class]);
    NSLog(@"获取Person类的父类名：%@",class);
}

#pragma mark -- 创建一个实例对象
+(void)createObject {
    //  cls: 类型
    //  extraBytes: 分配的内存大小
    //  返回值: cls类型的实例对象
    size_t size = class_getInstanceSize([Person class]);
    Person *ren = class_createInstance([Person class], size);
    NSLog(@"创建一个实例对象 ren 类大小 ： %zu 对象地址：%@",size,ren);
}

#pragma mark -- 获取一个类中, 实例成员变量的信息
+(void)getInstanceVariableInfo {
    NSLog(@"\n");
    //        cls: 类型
    //    name: 成员变量名（属性带 "_"）
    //    返回值: 成员变量信息
    Ivar ivar = class_getInstanceVariable([Person class], "_person");
    //获取Ivar的名称
    const char *ivar_getName(Ivar ivar);
    //获取Ivar的类型编码,
    const char *ivar_getTypeEncoding(Ivar ivar);
    
    NSString *name   = [NSString stringWithCString:ivar_getName(ivar) encoding:NSUTF8StringEncoding];
    //得到类型
    NSString *type   = [NSString stringWithCString:ivar_getTypeEncoding(ivar) encoding:NSUTF8StringEncoding];
    NSLog(@"获取成员变量 person的信息：name: %@  type: %@",name,type);
    
    [TestMethodSwizzling getAddInstanceVariableInfo];
}

+(void)getAddInstanceVariableInfo {
    /**
      Ivar的相关操作
     //获取Ivar的名称
     const char *ivar_getName(Ivar v);
     //获取Ivar的类型编码,
     const char *ivar_getTypeEncoding(Ivar v)
     //通过变量名称获取类中的实例成员变量
     Ivar class_getInstanceVariable(Class cls, const char *name)
     //通过变量名称获取类中的类成员变量
     Ivar class_getClassVariable(Class cls, const char *name)
     //获取指定类的Ivar列表及Ivar个数
     Ivar *class_copyIvarList(Class cls, unsigned int *outCount)
     //获取实例对象中Ivar的值
     id object_getIvar(id obj, Ivar ivar)
     //设置实例对象中Ivar的值
     void object_setIvar(id obj, Ivar ivar, id value)
     */
    //在运行时创建继承自NSObject的People类
    Class People = objc_allocateClassPair([NSObject class], "People", 0);
    NSLog(@"运行时 开始创建 People类 ");
    //添加_name成员变量
    BOOL flag1 = class_addIvar(People, "_name", sizeof(NSString*), log2(sizeof(NSString*)), @encode(NSString*));
    if (flag1) {
        NSLog(@"People 中 NSString*类型  _name变量添加成功");
    }
    //添加_age成员变量
    BOOL flag2 = class_addIvar(People, "_age", sizeof(int), sizeof(int), @encode(int));
    if (flag2) {
        NSLog(@"People 中 int类型 _age变量添加成功");
    }
    //完成People类的创建
    objc_registerClassPair(People);
    NSLog(@"运行时 People 类创建成功");
    
    unsigned int varCount;
    //拷贝People类中的成员变量列表
    Ivar * varList = class_copyIvarList(People, &varCount);
    for (int i = 0; i<varCount; i++) {
        NSLog(@"People类中有成员变量 %s",ivar_getName(varList[i]));
    }
    //释放varList
    free(varList);
    
    //创建People对象p1
    id p1 = [[People alloc]init];
    NSLog(@"创建 People实例对象 p1");
    //从类中获取成员变量Ivar
    Ivar nameIvar = class_getInstanceVariable(People, "_name");
    Ivar ageIvar = class_getInstanceVariable(People, "_age");
    //为p1的成员变量赋值
    object_setIvar(p1, nameIvar, @"张三");
    object_setIvar(p1, ageIvar, @33);
    //获取p1成员变量的值
    NSLog(@"给p1 成员变量赋值成功 %@",object_getIvar(p1, nameIvar));
    NSLog(@"给p1 成员变量赋值成功 %@",object_getIvar(p1, ageIvar));
}

#pragma mark -- 属性相关  获取信息、增加属性
+(void)getPropertyInfo {
    NSLog(@"\n");
    objc_property_t property = class_getProperty([Person class], "person");
    NSLog(@"获取Person类 person属性的名称  %s",property_getName(property));
    NSLog(@"person属性的特性字符串为: %s",property_getAttributes(property));
    [TestMethodSwizzling getAddpropertyInfo];
}

+(void)getAddpropertyInfo {
    /**
     特性编码 具体含义
     R readonly
     C copy
     & retain
     N nonatomic
     G(name) getter=(name)
     S(name) setter=(name)
     D @dynamic
     W weak
     P 用于垃圾回收机制
     
     //替换类中的属性
     void class_replaceProperty(Class cls, const char *name, const objc_property_attribute_t *attributes, unsigned int attributeCount)
     //获取类中的属性
     objc_property_t class_getProperty(Class cls, const char *name)
     //拷贝类中的属性列表
     objc_property_t *class_copyPropertyList(Class cls, unsigned int *outCount)
     //获取属性名称
     const char *property_getName(objc_property_t property)
     //获取属性的特性
     const char *property_getAttributes(objc_property_t property)
     //拷贝属性的特性列表
     objc_property_attribute_t *property_copyAttributeList(objc_property_t property, unsigned int *outCount)
     //拷贝属性的特性的值
     char *property_copyAttributeValue(objc_property_t property, const char *attributeName)
     */
    
    //  创建一个 临时 People类
    //    Class People = objc_allocateClassPair([NSObject class], "People", 0);
    //    objc_registerClassPair(People);
    
    //T@
    objc_property_attribute_t attributes1;
    attributes1.name = "T";
    attributes1.value = @encode(NSString*);
    
    // noatomic
    objc_property_attribute_t attributes2 = {"N",""};
    //Copy
    objc_property_attribute_t attribute3 = {"C",""};
    //V_属性名
    objc_property_attribute_t attribute4 = {"V","_peopleName"};
    
    //特性数组
    objc_property_attribute_t attributes[] = {attributes1,attributes2,attribute3,attribute4};
    
    //向Person类中添加名为name的属性,属性的4个特性包含在attributes中
    class_addProperty([Person class], "peopleName", attributes, 4);
    NSLog(@"向 person类中增加属性 peopleName");
    //获取类中的属性列表
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([Person class], &propertyCount);
    for (int i = 0; i<propertyCount; i++) {
        NSLog(@"person类的属性有  %s",property_getName(properties[i]));
        NSLog(@"属性的特性字符串为: %s",property_getAttributes(properties[i]));
    }
    
    //释放属性列表数组
    free(properties);
}

#pragma mark -- 获取对象方法信息
+(void)getInstanceMethodInfo {
    NSLog(@"\n");
    Method method = class_getInstanceMethod([Person class], @selector(personInfo:));
    //1.获取方法
    NSLog(@"获取到的方法名： %@",[NSString stringWithFormat:@"%@",NSStringFromSelector(method_getName(method))]);
    NSLog(@"获取到的方法类型： %@",[NSString stringWithFormat:@"%s",method_getTypeEncoding(method)]);
    
    //2.获取方法里的输入参数
    unsigned int argCount = method_getNumberOfArguments(method);
    char argName[512] = {};
    for (int j = 0; j< argCount; j++) {
        method_getArgumentType(method, j, argName, 512);
        NSLog(@"参数类型:%s",argName);
        memset(argName, '\0', strlen(argName));
    }
    
    //3.获取方法返回值类型
    char retType[512] = {};
    method_getReturnType(method, retType, 512);
    NSLog(@"返回类型值类型:%s",retType);
    [TestMethodSwizzling getClassMethodInfo];
}

+(void)getClassMethodInfo {
    Method method = class_getClassMethod([Person class], @selector(personPublic));
    NSLog(@"获取到的 +方法名： %@",[NSString stringWithFormat:@"%@",NSStringFromSelector(method_getName(method))]);
    NSLog(@"获取到的 +方法类型： %@",[NSString stringWithFormat:@"%s",method_getTypeEncoding(method)]);
    
    [TestMethodSwizzling getAddMethod];
    
    [Person dynamicAddMethod];
//    IMP imp = class_getMethodImplementation([Person class], @selector(personPublic));
    NSLog(@"获取到personPublic方法指针");
    
    // 获取方法列表
    unsigned int count;
    Method *methodList = class_copyMethodList([Person class], &count);
    for (int i = 0; i < count; i++) {
        Method method = methodList[i];
        NSLog(@"获取到方法 %s %s",__func__,sel_getName(method_getName(method)));
    }
}

+(void)getAddMethod {
    if (class_addMethod([Person class], NSSelectorFromString(@"zhjFuntion:"), class_getMethodImplementation([Person class], NSSelectorFromString(@"zhjFuntion:")), "v@:@")) {
        NSLog(@"成功添加了一个方法 %s ",__func__);
    } else {
        NSLog(@"添加了一个方法 失败 %s ",__func__);
    }
    [TestMethodSwizzling judgeClassHasFuntion:@selector(zhjFuntion:)];
}

+(void)judgeClassHasFuntion:(SEL)name {
    if (class_respondsToSelector([Person class], name)) {
        NSLog(@"%s %@ 存在", __func__, NSStringFromClass([Person class]));
    }else{
        NSLog(@"%s %@ 不存在", __func__, NSStringFromClass([Person class]));
    }
    
    if (class_isMetaClass([Person class])) {
        NSLog(@"%s %@ 是基类", __func__, NSStringFromClass([Person class]));
    }else{
        NSLog(@"%s %@ 不是 基类non-isMetaClass", __func__, NSStringFromClass([Person class]));
    }
}

#pragma mark -- 协议
////    获取协议列表
//    unsigned int counts;
//    Protocol *protocolList = class_copyProtocolList([Person class],&counts);
//    for (int i = 0; i < count; i++) {
//        Protocol *protocol = protocolList[i];
//        NSLog(@"%s%s", __func__, [self protocol_getName:protocol]);
//    }
@end
