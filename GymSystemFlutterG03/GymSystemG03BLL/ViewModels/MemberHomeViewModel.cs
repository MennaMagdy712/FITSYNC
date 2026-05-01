namespace GymSystemG03BLL.ViewModels
{
    public class MemberHomeViewModel
    {
        public int Id { get; set; }
        public string Name { get; set; } = null!;
        public string? Photo { get; set; }
        public string? PlanName { get; set; }
        public string? MemberShipEndDate { get; set; }
        public int UpcomingSessionsCount { get; set; }
    }
}
