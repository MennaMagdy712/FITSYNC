using AutoMapper;
using GymSystemG03BLL.ViewModels.BookingViewModel;
using GymSystemG03BLL.ViewModels.MembershipsViewModel;
using GymSystemG03BLL.ViewModels.SessionsViewModel;
using GymSystemG03DAL.Entites;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GymSystemG03BLL
{
    public class MappingProfiles : Profile
    {
        public MappingProfiles()
        {
            CreateMap<Session, SessionViewModel>()
                .ForMember(dest => dest.CategoryName, Options => Options.MapFrom(src => src.SessionCategory.CategoryName))
                .ForMember(dest => dest.TrainerName, Options => Options.MapFrom(src => src.SessionTrainer.Name))
                .ForMember(dest => dest.AvailableSlot, Options => Options.Ignore());
            //Avaliable slot will be handle in session servies

            CreateMap<CreateSessionViewModel, Session>();
            CreateMap<UpdateSessionViewModel, Session>().ReverseMap();
            CreateMap<Trainer, TrainerSelectViewModel>();
            CreateMap<Category, CategorySelectViewModel>()
                .ForMember(dest => dest.Name, Options => Options.MapFrom(src => src.CategoryName));
            //    .ForMember(dest => dest.CatgoryName, opt => opt.MapFrom(src => src.CatgoryName));
            MapMembership();
            MapBooking();

        }
        private void MapMembership()
        {
            CreateMap<Membership, MembershipViewModel>()
                .ForMember(dest => dest.MemberName,
                    opt => opt.MapFrom(src =>
                        src.Member != null ? src.Member.Name : "No Member"))

                .ForMember(dest => dest.PlanName,
                    opt => opt.MapFrom(src =>
                        src.Plan != null ? src.Plan.Name : "No Plan"))

                .ForMember(dest => dest.StartDate,
                    opt => opt.MapFrom(src => src.CreatedAt));

            CreateMap<CreateMembershipViewModel, Membership>();

            CreateMap<Member, MemberSelectListViewModel>();
            CreateMap<Plan, PlanSelectListViewModel>();
        }

        private void MapBooking()
        {
            CreateMap<MemberSession, MemberForSessionViewModel>()
                .ForMember(dest => dest.MemberName, opt => opt.MapFrom(src => src.Member.Name))
                .ForMember(dest => dest.BookingDate, opt => opt.MapFrom(src => src.CreatedAt.ToString()));

            CreateMap<CreateBookingViewModel, MemberSession>();

        }
    }
}
