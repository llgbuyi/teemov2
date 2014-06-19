<?php

//你应该在.h文件顶部放入如下信息，然后在命令行执行 php Pods/TeemoV2/TModel.php
//你可以将必要的信息放置在Pods/TeemoV2/cookie/目录下
//比如，需要在bbs.duowan.com域下传输指定cookie信息，则在cookie目录下放置一个文件名为bbs.duowan.com的文件，文件内容为cookie
//若PostData:为空，则为GET方式获取示例数据，格式如下PostData:id=123&name=你妹&sex=male
//【你也可以在h文件的目录下放置同名的.json后缀文件，程序将以此json文件内容为准，生成对应的数据结构】

/**
 *  TModel
 *  Url:http://duanzi.duowan.com/index.php?r=duanzi/topicList&page=1&pageSize=10&type=1&sort=2
 *  PostData:
 *  Usage: Open Terminal -> cd $projectDir -> php Pods/TeemoV2/TModel.php -> Done!
 *  Note that your project directory must Writeable -> sudo chown -R (User) ./
 */

//  These Code Is Generate By TModel cuiminghui@yy.com

$m = new TModel;
$m -> scan();
$m -> tryFetch();

class TModel {
     private $_Files = array();

     public function scan($dir = './') {
          $fileList = scandir($dir);
          foreach($fileList as $fileItem) {
               if($fileItem == '.' || $fileItem == '..'){
                    continue;
               }
               elseif(is_dir($dir.$fileItem)) {
                    $this -> scan($dir.$fileItem.'/');
               }
               else {
                    $this -> checkFile($dir.$fileItem);
               }
          }
     }

     public function checkFile($filePath) {
          $info = pathinfo($filePath);
          if($info['extension'] == 'h'){
               $this -> checkIfTModelFile($filePath);
          }
     }

     public function checkIfTModelFile($filePath) {
          $fileContents = file_get_contents($filePath);
          if(strpos($fileContents, 'TModel') !== false){
               if(strpos($fileContents, 'Locked!') === false){
                    $this -> _Files[] = $filePath;
                    echo '头文件:'.$filePath.' 已加入队列'.chr(10);
               }
          }
     }

     public function tryFetch() {
          foreach($this -> _Files as $fileItem) {
               if(is_file(substr_replace($fileItem, "json", -1))) {
                    //优先处理同名json文件
                    $jsonString = file_get_contents(substr_replace($fileItem, "json", -1));
                    $this -> _generateCode($fileItem, $jsonString);
                    continue;
               }
               $fileContents = file_get_contents($fileItem);
               preg_match('/\*.*?url:(.*?)\n/i', $fileContents, $urlMatch);
               preg_match('/\*.*?PostData:(.*?)\n/i', $fileContents, $postDataMatch);
               if(empty($urlMatch)){
                    echo '错误：'.$fileItem.'【URL缺失】'.chr(10);
                    continue;
               }
               if(!empty($postDataMatch[1])) {
                    //Post Method
                    $jsonString = $this -> _curlPost($urlMatch[1], $postDataMatch[1]);
               }
               else {
                    //Get Method
                    $jsonString = $this -> _curlGet($urlMatch[1]);
               }
               if(!empty($jsonString)){
                    $this -> _generateCode($fileItem, $jsonString);
               }
          }
     }

     private function _curlPost($url, $postData) {
          $urlScheme = parse_url($url);
          $ch = curl_init();
          curl_setopt($ch, CURLOPT_URL, $url);
          curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
          curl_setopt($ch, CURLOPT_POST, TRUE);
          curl_setopt($ch, CURLOPT_POSTFIELDS, $postData);
          if(is_file(dirname(__file__).$urlScheme['host'])){
               curl_setopt($ch, CURLOPT_COOKIE, file_get_contents(dirname(__file__).$urlScheme['host']));
          }
          $body = curl_exec($ch);
          curl_close($ch);
          return $body;
     }


     private function _curlGet($url) {
          $urlScheme = parse_url($url);
          $ch = curl_init();
          curl_setopt($ch, CURLOPT_URL, $url);
          curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
          if(is_file(dirname(__file__).$urlScheme['host'])){
               curl_setopt($ch, CURLOPT_COOKIE, file_get_contents(dirname(__file__).$urlScheme['host']));
          }
          $body = curl_exec($ch);
          curl_close($ch);
          return $body;
     }

     private function _generateCode($filePath, $jsonString) {
          $objects = json_decode($jsonString, true);
          if(!empty($objects)) {
               //开始生成代码
               $hCodeContents = file_get_contents($filePath);
               $BaseClassName = basename($filePath, '.h');
               $meta = explode('*/',$hCodeContents);
               $meta = $meta[0]."*/\n\n//  These Code Is Generate By TModel cuiminghui@yy.com\n//  Locked!This File has been Locked!!!If you eager to regenerate, PLEASE REMOVE THIS LINE.\n\n";
               $hCode = "";
               $classCode = "";
               $hCode .= $this -> _generateInterface($BaseClassName, $objects, $classCode);
               $hCode = "#import <Foundation/Foundation.h>\n\n".$classCode."\n".$hCode;
               $codeMerge = $meta.$hCode;
               file_put_contents($filePath,$codeMerge);

               $mCodeContents = '#import "'.$BaseClassName.'.h"'."\n".'#import <TMOToolKitCore.h>'."\n\n";
               $mCode = "";
               $interfaceCode = "";
               $mCode .= $this -> _generateImplementation($BaseClassName, $objects, $interfaceCode);
               $mCodeMerge = $mCodeContents.$interfaceCode.$mCode;
               file_put_contents(substr_replace($filePath, "m", -1),$mCodeMerge);
          }
     }

     private function _generateInterface($path, $object, &$classCode) {

          $code = '';
          $moreCode = "";
          $classCode .= "@class ".$path.";\n";

          if(gettype($object) == 'array'){
               if($this->_is_assoc_array($object)) {
                    //Root NSDictionary
                    $code = '@interface '.$path.' : NSObject'."\n\n";
                    $code .= '- (instancetype)initWithJSONString:(NSString *)argJSONString;'."\n@property (nonatomic, readonly) NSDictionary *_object;\n@property (nonatomic, readonly) NSError *_error;\n\n";
                    foreach($object as $key => $item) {
                         switch(gettype($item)){
                              case 'string':
                                   $code .= '@property (nonatomic, readonly) NSString *'.$key.';'."\n";
                              break;
                              case 'double':
                                   $code .= '@property (assign, readonly) CGFloat '.$key.';'."\n";
                              break;
                              case 'boolean':
                                   $code .= '@property (assign, readonly) BOOL '.$key.';'."\n";
                              break;
                              case 'integer':
                                   $code .= '@property (assign, readonly) NSInteger '.$key.';'."\n";
                              break;
                              case 'array':
                                   $code .= '@property (strong, readonly) '.$path.'_'.$key.' *'.$key.';'."\n";
                                   $moreCode .= $this -> _generateInterface($path.'_'.$key, $item, $classCode);
                              break;
                              case 'NULL':
                                   $code .= '@property (nonatomic, readonly) NSNull *'.$key.';'."\n";
                              break;
                         }
                    }
               }
               else {
                    //Root NSArray
                    $code = '@interface '.$path.' : NSObject'."\n\n";
                    $code .= '- (instancetype)initWithJSONString:(NSString *)argJSONString;'."\n@property (nonatomic, readonly) NSArray *_object;\n@property (nonatomic, readonly) NSError *_error;\n- (NSUInteger)count;\n\n";
                    foreach($object[0] as $key => $item) {
                         switch(gettype($item)){
                              case 'string':
                                   $code .= '- (NSString *)'.$key.':(NSInteger)atIndex;'."\n";
                              break;
                              case 'double':
                                   $code .= '- (CGFloat)'.$key.':(NSInteger)atIndex;'."\n";
                              break;
                              case 'boolean':
                                   $code .= '- (BOOL)'.$key.':(NSInteger)atIndex;'."\n";
                              break;
                              case 'integer':
                                   $code .= '- (NSInteger)'.$key.':(NSInteger)atIndex;'."\n";
                              break;
                              case 'array':
                                   $code .= '- ('.$path.'_'.$key.' *)'.$key.':(NSInteger)atIndex;'."\n";
                                   $moreCode .= $this -> _generateInterface($path.'_'.$key, $item, $classCode);
                              break;
                              case 'NULL':
                                   $code .= '- (NSNull *)'.$key.':(NSInteger)atIndex;'."\n";
                              break;
                         }
                    }
                    $code .= '- ('.$path.' *)appendToObject:('.$path.' *)argObject appendIndex:(NSInteger)appendIndex;'."\n";
               }
          }

          $code .= "\n@end\n\n";
          $code .= $moreCode;

          return $code;
     }

     private function _generateImplementation($path, $object, &$interfaceCode) {
          $code = "@implementation $path\n\n";
          $moreCode = "";
          $interfaceCode .= "@interface ".$path." (){\n    NSMutableDictionary *childObject;\n}\n@property (strong, nonatomic) id parsedObject;\n@end\n\n";

          if(gettype($object) == 'array'){
               if($this->_is_assoc_array($object)) {
                    //Root NSDictionary
                    $code .= "- (instancetype)init {\n    self = [super init];\n    if (self) {\n        childObject = [NSMutableDictionary dictionary];\n    }\n    return self;\n}"."\n\n";
                    $code .= "- (instancetype)initWithJSONString:(NSString *)argJSONString {\n    self = [super init];\n    if (self) {\n        _parsedObject = [NSJSONSerialization JSONObjectWithData:[argJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];\n        childObject = [NSMutableDictionary dictionary];\n    }\n    return self;\n}"."\n\n";
                    $code .= "- (NSDictionary *)_object {\n    return self.parsedObject;\n}"."\n\n";
                    $code .= "- (NSError *)_error {\n    if (_parsedObject == nil) {\n        return [NSError errorWithDomain:@\"JSONKit\" code:0 userInfo:nil];\n    }\n    //你还可以自定义你认为是错误的判断\n    return nil;\n}"."\n\n";
                    $code .= "- (id)valueForKey:(NSString *)key {\n    return TODictionary(_parsedObject[key]);\n}"."\n\n";
                    foreach($object as $key => $item) {
                         switch(gettype($item)){
                              case 'string':
                                   $code .= "- (NSString *)$key {\n    return TOString(_parsedObject[@\"$key\"]);\n}"."\n\n";
                              break;
                              case 'double':
                                   $code .= "- (CGFloat)$key {\n    return TOFloat(_parsedObject[@\"$key\"]);\n}"."\n\n";
                              break;
                              case 'boolean':
                                   $code .= "- (BOOL)$key {\n    return TOInteger(_parsedObject[@\"$key\"]);\n}"."\n\n";
                              break;
                              case 'integer':
                                   $code .= "- (NSInteger)$key {\n    return TOInteger(_parsedObject[@\"$key\"]);\n}"."\n\n";
                              break;
                              case 'array':
                                   $code .= "- ({$path}_{$key} *)$key {\n    __weak {$path}_{$key} *thisChildObject;\n    if (childObject[@\"$key\"] == nil) {\n        {$path}_{$key} *initedChildObject = [[{$path}_{$key} alloc] init];\n        thisChildObject = initedChildObject;\n        thisChildObject.parsedObject = self.parsedObject[@\"$key\"];\n        [childObject setObject:initedChildObject forKey:@\"$key\"];\n    }\n    else {\n        thisChildObject = childObject[@\"$key\"];\n    }\n    return thisChildObject;\n}"."\n\n";
                                   $moreCode .= $this -> _generateImplementation($path.'_'.$key, $item, $interfaceCode);
                              break;
                              case 'NULL':
                                   $code .= "- (NSNull *)$key {\n    return [NSNull null];\n}"."\n\n";
                              break;
                         }
                    }
               }
               else {
                    //Root NSArray
                    $code .= "- (instancetype)init {\n    self = [super init];\n    if (self) {\n        childObject = [NSMutableDictionary dictionary];\n    }\n    return self;\n}"."\n\n";
                    $code .= "- (instancetype)initWithJSONString:(NSString *)argJSONString {\n    self = [super init];\n    if (self) {\n        _parsedObject = [NSJSONSerialization JSONObjectWithData:[argJSONString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];\n        childObject = [NSMutableDictionary dictionary];\n    }\n    return self;\n}"."\n\n";
                    $code .= "- (NSArray *)_object {\n    return self.parsedObject;\n}"."\n\n";
                    $code .= "- (NSError *)_error {\n    if (_parsedObject == nil) {\n        return [NSError errorWithDomain:@\"JSONKit\" code:0 userInfo:nil];\n    }\n    //你还可以自定义你认为是错误的判断\n    return nil;\n}"."\n\n";
                    $code .= "- (id)objectAtIndex:(NSUInteger)index {\n    if (ISValidArray(_parsedObject, index)) {\n        return _parsedObject[index];\n    }\n    return nil;\n}"."\n\n";
                    $code .= "- (NSUInteger)count {\n    if ([self.parsedObject isKindOfClass:[NSArray class]]) {\n        return [self.parsedObject count];\n    }\n    return 0;\n}\n"."\n\n";
                    foreach($object[0] as $key => $item) {
                         switch(gettype($item)){
                              case 'string':
                                   $code .= "- (NSString *)$key:(NSInteger)atIndex {\n    return TOString([self objectAtIndex:atIndex][@\"$key\"]);\n}"."\n\n";
                              break;
                              case 'double':
                                   $code .= "- (CGFloat)$key:(NSInteger)atIndex {\n    return TOFloat([self objectAtIndex:atIndex][@\"$key\"]);\n}"."\n\n";
                              break;
                              case 'boolean':
                                   $code .= "- (BOOL)$key:(NSInteger)atIndex {\n    return TOInteger([self objectAtIndex:atIndex][@\"$key\"]);\n}"."\n\n";
                              break;
                              case 'integer':
                                   $code .= "- (NSInteger)$key:(NSInteger)atIndex {\n    return TOInteger([self objectAtIndex:atIndex][@\"$key\"]);\n}"."\n\n";
                              break;
                              case 'array':
                                   $code .= "- ({$path}_{$key} *)$key:(NSInteger)atIndex {\n    __weak {$path}_{$key} *thisChildObject;\n    NSString *theKey = [NSString stringWithFormat:@\"$key_%d\", atIndex];\n    if (childObject[theKey] == nil) {\n        {$path}_{$key} *initedChildObject = [[{$path}_{$key} alloc] init];\n        thisChildObject = initedChildObject;\n        thisChildObject.parsedObject = self.parsedObject[theKey];\n        [childObject setObject:initedChildObject forKey:theKey];\n    }\n    else {\n        thisChildObject = childObject[theKey];\n    }\n    return thisChildObject;\n}"."\n\n";
                                   $moreCode .= $this -> _generateImplementation($path.'_'.$key, $item, $interfaceCode);
                              break;
                              case 'NULL':
                                   $code .= "- (NSNull *)$key {\n    return [NSNull null];\n}"."\n\n";
                              break;
                         }
                    }
                    $code .= "- ({$path} *)appendToObject:({$path} *)argObject appendIndex:(NSInteger)appendIndex {\n    NSMutableArray *mutableArray;\n    if ([argObject.parsedObject isKindOfClass:[NSArray class]]) {\n        mutableArray = [argObject.parsedObject mutableCopy];\n    }\n    else {\n        mutableArray = [NSMutableArray array];\n    }\n    if (appendIndex < 0) {\n        [mutableArray addObjectsFromArray:self.parsedObject];\n        [argObject setParsedObject:[mutableArray copy]];\n        return argObject;\n    }\n    else {\n        if (ISValidArray(self.parsedObject, appendIndex)) {\n            [mutableArray addObject:self.parsedObject[appendIndex]];\n            [argObject setParsedObject:[mutableArray copy]];\n            return argObject;\n        }\n    }\n    return argObject;\n}\n\n";
               }
          }

          $code .= "@end\n\n////////////////////////////////////////////////////////////////////////////////////////////////////\n\n";
          $code .= $moreCode;

          return $code;
     }

     private function _is_assoc_array($array)
     {
          return array_keys($array) !== range(0, count($array) - 1);
     }

}
