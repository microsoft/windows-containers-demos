//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

using System; 
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;

namespace TicketDesk.Domain.Models.DataAnnotations
{
    public partial class AdCachedRoleMemberMeta
    {
    		
    	[DisplayName("Group Name")]
    	[Required]
    	[StringLength(150)]
        public string GroupName { get; set; }
    		
    	[DisplayName("Member Name")]
    	[Required]
    	[StringLength(150)]
        public string MemberName { get; set; }
    		
    	[DisplayName("Member Display Name")]
    	[Required]
    	[StringLength(150)]
        public string MemberDisplayName { get; set; }
    }
}
