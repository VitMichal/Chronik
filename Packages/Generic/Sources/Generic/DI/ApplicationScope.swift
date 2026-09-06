import Swinject

public final class ApplicationScope {
    static var assembler = Assembler([])
    
    public static func set(assemblies: [Assembly]) {
        assembler = Assembler(assemblies)
    }
    
    public static func resolve<Service>(_ type: Service.Type) -> Service {
        assembler.resolver.resolve(Service.self)!
    }
    
    public static func resolve<Service, Arg>(_ type: Service.Type, argument: Arg) -> Service {
        assembler.resolver.resolve(Service.self, argument: argument)!
    }
}

