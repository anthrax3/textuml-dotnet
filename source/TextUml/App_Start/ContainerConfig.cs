﻿namespace TextUml
{
    using System;
    using System.Configuration;
    using System.Reflection;
    using System.Threading;
    using System.Web;
    using System.Web.Http;
    using System.Web.Mvc;

    using Microsoft.AspNet.SignalR;

    using Autofac;
    using Autofac.Builder;
    using Autofac.Integration.Mvc;
    using Autofac.Integration.SignalR;
    using Autofac.Integration.WebApi;

    using Postal;

    using DataAccess;
    using Infrastructure;
    using Properties;
    using Services;

    using MvcResolver = Autofac.Integration.Mvc.AutofacDependencyResolver;
    using SignalrResolver = Autofac.Integration.SignalR.AutofacDependencyResolver;
    using WebApiResolver = Autofac.Integration.WebApi.AutofacWebApiDependencyResolver;

    public static class ContainerConfig
    {
        public static void Register()
        {
            var assemblies = new[] { Assembly.GetExecutingAssembly() };

            RegisterMvc(assemblies);
            RegisterWebApi(assemblies);
            RegisterSignalr(assemblies);
        }

        private static void RegisterMvc(Assembly[] assemblies)
        {
            var builder = CreateContainerBuilder();

            builder.RegisterControllers(assemblies);
            builder.RegisterModelBinders(assemblies);
            builder.RegisterModelBinderProvider();
            builder.RegisterFilterProvider();

            Register<CookieTempDataProvider>(builder);

            var container = builder.Build();
            var resolver = new MvcResolver(container);

            DependencyResolver.SetResolver(resolver);
        }

        private static void RegisterWebApi(Assembly[] assemblies)
        {
            var configuration = GlobalConfiguration.Configuration;
            var builder = CreateContainerBuilder();

            builder.RegisterWebApiFilterProvider(configuration);
            builder.RegisterWebApiModelBinders(assemblies);
            builder.RegisterApiControllers(assemblies);

            var container = builder.Build();
            var resolver = new WebApiResolver(container);

            configuration.DependencyResolver = resolver;
        }

        private static void RegisterSignalr(Assembly[] assemblies)
        {
            var builder = CreateContainerBuilder();
            builder.RegisterHubs(assemblies);

            var container = builder.Build();
            var resolver = new SignalrResolver(container);

            GlobalHost.DependencyResolver = resolver;
        }

        private static ContainerBuilder CreateContainerBuilder()
        {
            var builder = new ContainerBuilder();
            var settings = ConfigurationManager.AppSettings;

            Register<UrlSafeSecureDataSerializer>(builder)
                .WithParameter(
                    "algorithm",
                    settings["urlSafeSecureData.algorithm"])
                .WithParameter("key", settings["urlSafeSecureData.key"])
                .WithParameter("vector", settings["urlSafeSecureData.vector"])
                .SingleInstance();

            builder.Register(c => new HttpContextWrapper(HttpContext.Current))
                .As<HttpContextBase>();

            Register<EmailService>(builder);
            Register<MailUrlResolver>(builder);

            Register<Mailer>(builder)
                .WithParameter("sender", Settings.Default.SupportEmailAddress);

            Register<MembershipService>(builder);
            Register<CurrentUserProvider>(builder);
            Register<DocumentService>(builder);
            Register<ShareService>(builder);
            Register<NewUserConfirmedHandler>(builder);
            Register<DataContext>(builder);

            return builder;
        }

        private static IRegistrationBuilder<TService,
            ConcreteReflectionActivatorData,
            SingleRegistrationStyle>
            Register<TService>(ContainerBuilder builder)
        {
            return builder.RegisterType<TService>()
                .AsImplementedInterfaces()
                .AsSelf();
        }
    }
}